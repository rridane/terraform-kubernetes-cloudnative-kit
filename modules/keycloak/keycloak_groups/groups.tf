# Groupes racines (sans parent)
resource "keycloak_group" "root_groups" {
  for_each = {
    for g in local.root_groups : g.name => g
  }

  realm_id   = var.realm_id
  name       = each.value.name
  attributes = each.value.attributes
}

# Groupes de niveau 1 (parent direct)
resource "keycloak_group" "level1_groups" {
  for_each = {
    for g in local.level1_groups : g.name => g
  }

  realm_id   = var.realm_id
  name       = basename(each.value.name)
  parent_id  = keycloak_group.root_groups[each.value.parent].id
  attributes = each.value.attributes

  depends_on = [keycloak_group.root_groups]
}

# Groupes de niveau 2
resource "keycloak_group" "level2_groups" {
  for_each = {
    for g in local.level2_groups : g.name => g
  }

  realm_id   = var.realm_id
  name       = basename(each.value.name)
  parent_id  = keycloak_group.level1_groups[each.value.parent].id
  attributes = each.value.attributes

  depends_on = [keycloak_group.level1_groups]
}

# Groupes de niveau 3
resource "keycloak_group" "level3_groups" {
  for_each = {
    for g in local.level3_groups : g.name => g
  }

  realm_id   = var.realm_id
  name       = basename(each.value.name)
  parent_id  = keycloak_group.level2_groups[each.value.parent].id
  attributes = each.value.attributes

  depends_on = [keycloak_group.level2_groups]
}
