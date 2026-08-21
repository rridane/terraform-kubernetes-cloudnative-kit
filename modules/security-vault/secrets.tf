locals {
  yaml_content = yamldecode(file(var.secret_config_file))
  mounts       = local.yaml_content["mounts"]

  # Vault KV secrets to create — one entry per (mount, name).
  all_secrets = flatten([
    for mount_name, mount in local.mounts : [
      for secret in lookup(mount, "secrets", []) : {
        mount  = mount_name
        name   = secret.name
        values = secret.values
      }
    ]
  ])

  # ESO projections — zero, one or many per Vault secret. Each item under
  # external_secrets becomes a separate ExternalSecret CR in its target namespace,
  # all reading the same Vault path.
  all_projections = flatten([
    for mount_name, mount in local.mounts : [
      for secret in lookup(mount, "secrets", []) : [
        for p in lookup(secret, "external_secrets", []) : {
          mount             = mount_name
          name              = secret.name
          values            = secret.values
          external_name     = p.name
          external_ns       = p.namespace
          secret_store_name = p.secret_store.name
          secret_store_kind = p.secret_store.kind
          # Optionnel : type du Secret K8s produit (ex. kubernetes.io/basic-auth).
          # Si absent -> Opaque (comportement historique).
          secret_type = lookup(p, "type", null)
          # Optionnel : labels posés sur le Secret K8s produit. Requis par ex. pour
          # qu'ArgoCD accepte de référencer le Secret via `$name:key` dans argocd-cm
          # (label `app.kubernetes.io/part-of: argocd` exigé). Si absent -> aucun label.
          secret_labels = lookup(p, "labels", null)
        }
      ]
    ]
  ])
}

resource "vault_mount" "mounts" {
  for_each = {
    for k, v in local.mounts : k => v
    if lookup(v, "create", false)
  }

  path        = each.key
  type        = var.default_mount_type
  description = "Any secret should be created by Terraform, do not manually create anything"
}

resource "random_password" "generated" {
  for_each = {
    for s in local.all_secrets :
    "${s["mount"]}/${s["name"]}/password" => s
    if contains(values(s["values"]), "@generated_password")
  }

  length  = 20
  special = true
}

resource "random_pet" "names" {
  for_each = {
    for s in local.all_secrets :
    "${s["mount"]}/${s["name"]}/name" => s
    if contains(values(s["values"]), "@generated_name")
  }
}

resource "vault_kv_secret_v2" "secrets" {
  for_each = {
    for s in local.all_secrets :
    "${s["mount"]}/${s["name"]}" => s
  }

  mount      = each.value["mount"]
  name       = each.value["name"]
  depends_on = [vault_mount.mounts]

  data_json = jsonencode({
    for key, val in each.value["values"] :
    key => (
      val == "@generated_password" ? random_password.generated["${each.value["mount"]}/${each.value["name"]}/password"].result :
      val == "@generated_name" ? random_pet.names["${each.value["mount"]}/${each.value["name"]}/name"].id :
      val
    )
  })

  lifecycle {
    ignore_changes = [data_json]
  }
}

resource "kubernetes_manifest" "external_secret" {
  for_each = {
    for p in local.all_projections :
    "${p["mount"]}/${p["name"]}/${p["external_ns"]}" => p
  }

  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = each.value["external_name"]
      namespace = each.value["external_ns"]
    }
    spec = {
      refreshInterval = "1h"
      secretStoreRef = {
        name = each.value["secret_store_name"]
        kind = each.value["secret_store_kind"]
      }
      # Quand un `type` et/ou des `labels` sont fournis, on passe par target.template
      # pour que ESO produise un Secret typé (ex. basic-auth, exigé par Fleet) et/ou
      # labellisé (ex. part-of: argocd) au lieu d'un simple Opaque sans label.
      # Chaque clé fetchée est réinjectée via le moteur de template ESO pour préserver
      # les données quand on active le templating.
      target = merge(
        {
          name           = each.value["external_name"]
          creationPolicy = "Owner"
        },
        (each.value["secret_type"] == null && each.value["secret_labels"] == null) ? {} : {
          # engineVersion / mergePolicy sont défaultés par le webhook ESO (v2 / Replace)
          # dès qu'un template est présent. On les déclare explicitement pour que le
          # contrôle de cohérence post-apply de kubernetes_manifest ne casse pas sur
          # « Provider produced inconsistent result after apply ».
          template = merge(
            {
              engineVersion = "v2"
              mergePolicy   = "Replace"
              data          = { for k, _ in each.value["values"] : k => "{{ .${k} }}" }
            },
            each.value["secret_type"] == null ? {} : { type = each.value["secret_type"] },
            each.value["secret_labels"] == null ? {} : { metadata = { labels = each.value["secret_labels"] } }
          )
        }
      )
      data = [
        for key, val in each.value["values"] : {
          secretKey = key
          remoteRef = {
            key      = each.value["name"]
            property = key
          }
        }
      ]
    }
  }

  field_manager {
    name            = "terraform"
    force_conflicts = true
  }

  depends_on = [
    vault_kv_secret_v2.secrets
  ]
}
