resource "keycloak_openid_client" "clients" {
  for_each = var.clients

  realm_id  = keycloak_realm.realm.id
  client_id = each.key

  name       = lookup(each.value, "name", each.key)
  access_type = each.value.access_type

  pkce_code_challenge_method = each.value.pkce_code_challenge_method

  valid_redirect_uris = each.value.redirect_uris
  web_origins   = each.value.web_origins

  standard_flow_enabled                = each.value.standard_flow_enabled
  service_accounts_enabled             = each.value.service_accounts_enabled
  implicit_flow_enabled                = each.value.implicit_flow_enabled
  direct_access_grants_enabled         = each.value.direct_access_grants_enabled
  oauth2_device_authorization_grant_enabled  = each.value.oauth2_device_authorization_enabled

}

resource "keycloak_openid_client_optional_scopes" "client_optional_scopes" {
  for_each = var.clients

  realm_id  = keycloak_realm.realm.id
  client_id = keycloak_openid_client.clients[each.key].id

  optional_scopes = each.value.optional_scopes

  depends_on = [keycloak_openid_client.clients]
}

resource "keycloak_openid_client_default_scopes" "client_default_scopes" {
  for_each = var.clients

  realm_id  = keycloak_realm.realm.id
  client_id = keycloak_openid_client.clients[each.key].id

  default_scopes = each.value.default_scopes

  depends_on = [keycloak_openid_client.clients, keycloak_openid_client_optional_scopes.client_optional_scopes]
}

