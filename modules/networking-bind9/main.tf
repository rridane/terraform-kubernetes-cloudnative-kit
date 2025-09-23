locals {
  zones_conf = join("\n", [
    for zone, _ in var.bind9_zones : <<EOT
      zone "${zone}" {
          type master;
          file "/etc/bind/db.${zone}";
      };
      EOT
  ])
}
resource "kubernetes_config_map" "bind9_conf" {

  metadata {
    name      = "bind9-conf"
    namespace = var.namespace
  }

  data = {
    "named.conf.local" = templatefile("${path.module}/templates/named.conf.local.tmpl", { zones = local.zones_conf })
    "named.conf.options" = var.bind_custom_options_file != "" ? file(var.bind_custom_options_file) :
      templatefile("${path.module}/templates/named.conf.options.tmpl", {
        bind_recursion         = var.bind_recursion
        bind_allow_query       = var.bind_allow_query
        bind_allow_query_cache = var.bind_allow_query_cache
        bind_forwarders        = var.bind_forwarders
        bind_listen_on_v6      = var.bind_listen_on_v6
        bind_dnssec_validation = var.bind_dnssec_validation
      })
  }

}

# ConfigMap pour chaque zone
resource "kubernetes_config_map" "zones" {
  for_each = var.bind9_zones

  metadata {
    name      = "zone-${replace(each.key, ".", "-")}"
    namespace = var.namespace
  }

  data = {
    "${each.key}" = file(each.value.zone_file)
  }
}

# Déploiement Bind9
resource "kubernetes_deployment" "bind9" {
  metadata {
    name      = "bind9"
    namespace = var.namespace
    labels = { app = "bind9" }
  }

  spec {
    selector {
      match_labels = { app = "bind9" }
    }

    template {
      metadata {
        labels = { app = "bind9" }
      }

      spec {
        container {
          name              = "bind9"
          image             = "ubuntu/bind9:edge"
          image_pull_policy = "IfNotPresent"

          port {
            container_port = 53
            protocol       = "UDP"
          }

          # Mount named.conf et options
          volume_mount {
            mount_path = "/etc/bind/named.conf.local"
            name       = "bind9-conf"
            sub_path   = "named.conf.local"
          }

          volume_mount {
            mount_path = "/etc/bind/named.conf.options"
            name       = "bind9-conf"
            sub_path   = "named.conf.options"
          }

          # Mount zones
          dynamic "volume_mount" {
            for_each = var.bind9_zones
            content {
              mount_path = "/etc/bind/db.${volume_mount.key}"
              name       = "zone-${replace(volume_mount.key, ".", "-")}"
              sub_path   = "${volume_mount.key}"
            }
          }
        }

        # Volumes globaux
        volume {
          name = "bind9-conf"
          config_map {
            name = kubernetes_config_map.bind9_conf.metadata[0].name
          }
        }

        dynamic "volume" {
          for_each = kubernetes_config_map.zones
          content {
            name = "zone-${replace(volume.key, ".", "-")}"
            config_map {
              name = volume.value.metadata[0].name
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "bind9" {
  metadata {
    name      = var.bind9_service_name
    namespace = var.namespace
    labels = { app = "bind9" }
  }

  spec {
    selector = { app = "bind9" }
    type = var.bind9_service_type

    port {
      port        = var.bind9_service_port
      target_port = 53
      name        = "dns"
      protocol    = "UDP"
      node_port   = var.bind9_node_port
    }
  }
}

resource "kubernetes_config_map" "dnsdist_conf" {
  count = var.dnsdist_enabled ? 1 : 0

  metadata {
    name      = "dnsdist-conf"
    namespace = var.namespace
  }

  data = {
    "dnsdist.conf" = <<EOT
    addDOHLocal("0.0.0.0:${var.dnsdist_port}", "/etc/dnsdist/certs/tls.crt", "/etc/dnsdist/certs/tls.key")
    newServer({address="${kubernetes_service.bind9.metadata[0].name}.${var.namespace}.svc.cluster.local", port=53})
  EOT
  }

}

resource "kubernetes_deployment" "dnsdist" {
  count = var.dnsdist_enabled ? 1 : 0

  metadata {
    name      = "dnsdist"
    namespace = var.namespace
    labels = { app = "dnsdist" }
  }

  spec {
    selector {
      match_labels = { app = "dnsdist" }
    }

    template {
      metadata {
        labels = { app = "dnsdist" }
      }

      spec {
        init_container {
          name  = "init-dnsdist-conf"
          image = "busybox:1.36"

          command = [
            "sh", "-c",
            <<-EOT
              set -eu
              IP=$(nslookup bind9-svc.bind9.svc.cluster.local | grep bind9 -A 1 | grep Address | awk -F ": " '{print $2}')
              echo "addDOHLocal(\"0.0.0.0:${var.dnsdist_port}\", \"/etc/dnsdist/certs/tls.crt\", \"/etc/dnsdist/certs/tls.key\")" > /work-dir/dnsdist.conf
              echo "newServer({address=\"$$IP\", checkName=\"${var.dnsdist_check_resolve_dns}\"})" >> /work-dir/dnsdist.conf
            EOT
          ]

          volume_mount {
            name       = "dnsdist-generated"
            mount_path = "/work-dir"
          }
        }


        # Conteneur principal dnsdist
        container {
          name  = "dnsdist"
          image = var.dnsdist_image

          port {
            container_port = var.dnsdist_port
            protocol       = "TCP"
          }

          volume_mount {
            name       = "dnsdist-generated"
            mount_path = "/etc/dnsdist/dnsdist.conf"
            sub_path   = "dnsdist.conf"
          }

          volume_mount {
            name       = "dnsdist-certs"
            mount_path = "/etc/dnsdist/certs"
            read_only  = true
          }
        }

        # Volumes
        volume {
          name = "dnsdist-generated"
          empty_dir {}
        }

        volume {
          name = "dnsdist-certs"
          secret {
            secret_name = var.dnsdist_cert_secret
          }
        }
      }
    }
  }
}


resource "kubernetes_service" "dnsdist" {
  count = var.dnsdist_enabled ? 1 : 0

  metadata {
    name      = var.dnsdist_service_name
    namespace = var.namespace
    labels = { app = "dnsdist" }
  }

  spec {
    selector = { app = "dnsdist" }
    type = var.dnsdist_service_type

    port {
      port        = var.dnsdist_svc_port
      target_port = var.dnsdist_port
      protocol    = "TCP"
      node_port   = var.dnsdist_node_port
    }
  }
}
