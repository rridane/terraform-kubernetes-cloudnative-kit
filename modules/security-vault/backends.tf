# Kubernetes backend
resource "vault_auth_backend" "kubernetes" {
  count = local.kubernetes_backend["managed"] == true ? 1 : 0
  type  = "kubernetes"
  path  = "kubernetes"
}

resource "vault_kubernetes_auth_backend_config" "kubernetes_config" {

  count = local.kubernetes_backend["managed"] == true ? 1 : 0

  backend = vault_auth_backend.kubernetes[0].path
  kubernetes_host = try(local.kubernetes_backend["config"]["kubernetes_host"], null)
  kubernetes_ca_cert = file(try(local.kubernetes_backend["config"]["kubernetes_ca_cert_file"], "/dev/null"))
  token_reviewer_jwt = file(try(local.kubernetes_backend["config"]["token_reviewer_jwt_file"], "/dev/null"))

}

# AppRole backend
resource "vault_auth_backend" "approle" {
  count = local.app_role_backend["managed"] == true ? 1 : 0
  type  = "approle"
  path  = "approle"
}

data "vault_kv_secret_v2" "oidc_secret" {

  count = local.oidc_backend["managed"] == true ? 1 : 0

  mount = local.oidc_backend["config"]["oidc_client_secret_vault_mount"]
  name  = local.oidc_backend["config"]["oidc_client_secret_vault_path"]

  depends_on = [vault_kv_secret_v2.secrets]
}

resource "vault_jwt_auth_backend" "oidc" {

  count = local.oidc_backend["managed"] == true ? 1 : 0

  path = "oidc"
  type = "oidc"
  description = try(local.oidc_backend["description"], "")
  oidc_discovery_url = try(local.oidc_backend["config"]["oidc_discovery_url"], null)
  oidc_client_id = try(data.vault_kv_secret_v2.oidc_secret[0].data[local.oidc_backend["config"]["oidc_client_id_vault_key"]], null)
  oidc_client_secret = try(data.vault_kv_secret_v2.oidc_secret[0].data[local.oidc_backend["config"]["oidc_client_secret_vault_key"]], null)
  default_role = try(local.oidc_backend["config"]["default_role"], null)

  depends_on = [data.vault_kv_secret_v2.oidc_secret]
}

