# Fonction helper pour trouver l'ID du groupe
locals {
  # Creates map : { "dev" => "id-group-dev" }
  group_ids = merge(
    { for k, v in keycloak_group.root_groups : k => v.id },
    { for k, v in keycloak_group.level1_groups : k => v.id },
    { for k, v in keycloak_group.level2_groups : k => v.id },
    { for k, v in keycloak_group.level3_groups : k => v.id }
  )
}

resource "keycloak_group_roles" "client_realm_group_roles" {
  for_each = {
    for g in var.groups : g.name => g
    if length(g.realm_roles) > 0 || length(keys(g.roles_by_client)) > 0
  }

  realm_id = var.realm_id
  group_id = local.group_ids[each.key]

  role_ids = sort(distinct(concat(
    # Realm roles
    [
      for role_name in each.value.realm_roles :
      var.realm_roles_ids[role_name]
    ],

    # Client roles (flatten multi-clients)
    flatten([
      for client_name, roles in each.value.roles_by_client : [
        for role_name in roles :
        var.client_roles_ids["${client_name}-${role_name}"]
      ]
    ])
  )))
}
