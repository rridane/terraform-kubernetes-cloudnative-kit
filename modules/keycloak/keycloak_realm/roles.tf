locals {
  client_roles = merge([
    for client_name, client in var.clients : {
      for role in client.roles : "${client_name}-${role}" => { client_name = client_name, role = role }
    }
  ]...)

  service_account_roles = merge(flatten([
    for account, client in var.clients : [
      for target, roles in client.service_account_roles : {
        for role in roles : "${account}-${target}-${role}" => { account = account, target = target, role = role }
      }
    ]
  ])...)
}

resource "keycloak_role" "client_roles" {
  for_each = local.client_roles

  realm_id  = keycloak_realm.realm.id
  client_id = keycloak_openid_client.clients[each.value.client_name].id
  name      = each.value.role
}

resource "keycloak_openid_client_service_account_role" "service_account_roles" {
  for_each = local.service_account_roles

  realm_id                = keycloak_realm.realm.id
  service_account_user_id = keycloak_openid_client.clients[each.value.account].service_account_user_id
  client_id               = keycloak_openid_client.clients[each.value.target].id
  role                    = keycloak_role.client_roles["${each.value.target}-${each.value.role}"].name
}
