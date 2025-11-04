# Kubernetes roles
resource "vault_kubernetes_auth_backend_role" "generated" {
  for_each = {
    for r in local.roles_list : r["name"] => r
    if r["type"] == "kubernetes"
  }

  backend                          = "kubernetes"
  role_name                        = each.value["name"]
  bound_service_account_names      = each.value["service_accounts"]
  bound_service_account_namespaces = [each.value["namespace"]]
  token_ttl                        = try(each.value["ttl_hours"], 1)
  token_policies                   = each.value["policies"]
  audience                         = try(each.value["audience"], "vault")
}

# AppRole roles

resource "vault_approle_auth_backend_role" "generated" {
  for_each = {
    for r in local.roles_list : r["name"] => r
    if r["type"] == "approle"
  }

  backend        = vault_auth_backend.approle[0].path
  role_name      = each.value["name"]
  token_policies = each.value["policies"]
  token_ttl      = try(each.value["token_ttl_hours"], 1)
  token_max_ttl  = try(each.value["token_max_ttl_hours"], 8)
}

# OIDC / JWT roles

resource "vault_jwt_auth_backend_role" "generated" {
  for_each = {
    for r in local.roles_list : r["name"] => r
    if r["type"] == "oidc" || r["type"] == "jwt"
  }

  backend        = vault_jwt_auth_backend.oidc[0].path
  role_name      = each.value["name"]
  token_policies = each.value["policies"]

  # OIDC/JWT specifics
  user_claim            = try(each.value["user_claim"], "sub")
  role_type             = try(each.value["role_type"], each.value["type"])
  allowed_redirect_uris = try(each.value["allowed_redirect_uris"], [])
  bound_audiences       = try(each.value["bound_audiences"], [])
  bound_claims          = try(each.value["bound_claims"], {})

  # TTLs
  token_ttl     = try(each.value["token_ttl_hours"], 1)
  token_max_ttl = try(each.value["token_max_ttl_hours"], 8)
}



