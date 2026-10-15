locals {
  expanded_roles = flatten([
    for client_name, roles in var.roles_by_client : [
      for role in roles : {
        client_name = client_name
        client_id   = var.clients[client_name]
        role        = role
      }
    ]
  ])
}

resource "keycloak_role" "client_roles" {
  for_each = {
    for item in local.expanded_roles :
    "${item.client_name}-${item.role}" => item
  }

  realm_id  = var.realm_id
  client_id = each.value.client_id
  name      = each.value.role
}

locals {
  expanded_service_account_roles = flatten([
    for account, by_client in var.service_account_roles : [
      for client_name, roles in by_client : [
        for role in roles : { account = account, client_name = client_name, role = role }
      ]
    ]
  ])
}

resource "keycloak_openid_client_service_account_role" "this" {
  for_each = {
    for item in local.expanded_service_account_roles :
    "${item.account}-${item.client_name}-${item.role}" => item
  }

  realm_id                = var.realm_id
  service_account_user_id = var.service_account_user_ids[each.value.account]
  client_id               = var.clients[each.value.client_name]
  role                    = keycloak_role.client_roles["${each.value.client_name}-${each.value.role}"].name
}
