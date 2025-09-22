locals {
  # Génère le contenu complet de named.conf.local
  zones_conf = join("\n", [
    for k, v in var.zones : file(v.conf_file)
  ])
}

# ConfigMap pour named.conf.local et named.conf.options
resource "kubernetes_config_map" "bind9_conf" {

  metadata {
    name      = "bind9-conf"
    namespace = var.namespace
  }

  data = {
    "named.conf.local" = templatefile("${path.module}/templates/named.conf.local.tmpl", { zones = local.zones_conf })
    "named.conf.options" = file("${path.module}/templates/named.conf.options")
  }

}

# ConfigMap pour chaque zone
resource "kubernetes_config_map" "zones" {
  for_each = var.zones

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
            for_each = var.zones
            content {
              mount_path = "/etc/bind/${volume_mount.key}"
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

# Service
resource "kubernetes_service" "bind9" {
  metadata {
    name      = "bind9-svc"
    namespace = var.namespace
    labels = { app = "bind9" }
  }

  spec {
    selector = { app = "bind9" }
    type = "ClusterIP"

    port {
      target_port = 53
      port        = 53
      name        = "dns"
      protocol    = "UDP"
    }
  }
}
