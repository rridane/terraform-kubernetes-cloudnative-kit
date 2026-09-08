locals {
  expanded_groups = flatten([
    for group_name, group_def in var.groups :
    # concatène [groupe racine] + [éventuels sous-groupes]
    concat(
      [
        {
          name         = group_name
          parent       = null
          attributes   = try(group_def.attributes, {})
          realm_roles  = try(group_def.realm_roles, [])
          client_roles = try(group_def.client_roles, {})
        }
      ],
        group_def.subgroups != null ? [
        for sub_name, sub_def in group_def.subgroups : {
          name         = "${group_name}/${sub_name}"
          parent       = group_name
          attributes   = try(sub_def.attributes, {})
          realm_roles  = try(sub_def.realm_roles, [])
          client_roles = try(sub_def.client_roles, {})
        }
      ] : []
    )
  ])
}

resource "keycloak_group" "groups" {
  for_each = {
    for g in local.expanded_groups :
    g.name => g
  }

  realm_id = var.realm_id
  name     = each.value.name

  parent_id = each.value.parent != null ?
    keycloak_group.groups[each.value.parent].id :
    null

  attributes = each.value.attributes
}

resource "keycloak_group_roles" "realm_roles" {
  for_each = {
    for group in local.expanded_groups :
    group.name => group
    if length(group.realm_roles) > 0
  }

  realm_id = var.realm_id
  group_id = keycloak_group.groups[each.key].id

  role_ids = [
    for role_name in each.value.realm_roles :
    keycloak_realm_role.realm_roles[role_name].id
  ]
}

resource "keycloak_group_roles" "client_roles" {
  for_each = {
    for group in local.expanded_groups :
    group.name => group
    if length(keys(group.client_roles)) > 0
  }

  realm_id = var.realm_id
  group_id = keycloak_group.groups[each.key].id

  role_ids = flatten([
    for client_name, roles in each.value.client_roles : [
      for role_name in roles :
      keycloak_role.client_roles["${client_name}-${role_name}"].id
    ]
  ])
}
