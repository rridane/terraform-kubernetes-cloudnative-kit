locals {
  yaml_content = yamldecode(file(var.secret_config_file))
  mounts       = local.yaml_content["mounts"]

  all_secrets = flatten([
    for mount_name, mount in local.mounts : [
      for secret in lookup(mount, "secrets", []) : {
        mount            = mount_name
        name             = secret.name
        values           = secret.values
        external_enabled = lookup(secret, "external_secret", {})["enabled"]
        external_name    = lookup(secret, "external_secret", {})["name"]
        external_ns      = lookup(secret, "external_secret", {})["namespace"]
        secret_store_name     = lookup(
          lookup(secret, "external_secret", {}),
          "secret_store",
          {}
        )["name"]
        secret_store_kind     = lookup(
          lookup(secret, "external_secret", {}),
          "secret_store",
          {}
        )["kind"]
      }
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

  mount = each.value["mount"]
  name  = each.value["name"]
  depends_on = [vault_mount.mounts]

  data_json = jsonencode({
    for key, val in each.value["values"] :
    key => (
      val == "@generated_password" ? random_password.generated["${each.value["mount"]}/${each.value["name"]}/password"].result :
        val == "@generated_name"     ? random_pet.names["${each.value["mount"]}/${each.value["name"]}/name"].id :
        val
    )
  })

  lifecycle {
    ignore_changes = [data_json]
  }
}

resource "kubernetes_manifest" "external_secret" {
  for_each = {
    for s in local.all_secrets :
    "${s["mount"]}/${s["name"]}" => s
    if s["external_enabled"] == true
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
      target = {
        name           = each.value["external_name"]
        creationPolicy = "Owner"
      }
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
