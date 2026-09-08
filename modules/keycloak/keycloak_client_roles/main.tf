locals {
  expanded_roles = flatten([
    for client_name, roles in var.client_roles : [
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
