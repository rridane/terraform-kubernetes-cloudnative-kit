resource "keycloak_group_roles" "realm_roles" {
  for_each = {
    for g in local.sorted_groups :
    g.name => g if length(g.realm_roles) > 0
  }

  realm_id = var.realm_id
  group_id = keycloak_group.groups[each.key].id

  role_ids = [
    for role_name in each.value.realm_roles :
    var.realm_roles_ids[role_name]
  ]
}

resource "keycloak_group_roles" "client_roles" {
  for_each = {
    for g in local.sorted_groups :
    g.name => g if length(keys(g.client_roles)) > 0
  }

  realm_id = var.realm_id
  group_id = keycloak_group.groups[each.key].id

  role_ids = flatten([
    for client_name, roles in each.value.client_roles : [
      for role_name in roles :
      var.client_roles_ids["${client_name}-${role_name}"]
    ]
  ])
}
