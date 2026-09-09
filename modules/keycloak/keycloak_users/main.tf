# NB : dans Keycloak, l'id d'un realm EST son nom -> on utilise var.realm
# directement comme realm_id. Pas de data source (qui, différée par un
# depends_on côté appelant, rendrait realm_id "known after apply" et
# forcerait un remplacement du user via son attribut ForceNew realm_id).

########################################
# Résolution des groupes par NOM (unique)
########################################
locals {
  all_group_names = toset(flatten([for u in var.users : u.groups]))
}

data "keycloak_group" "by_name" {
  for_each = local.all_group_names
  realm_id = var.realm
  name     = each.key
}

########################################
# Users (deux modes : manage vs lookup)
########################################

# Mode 1: on **gère** les users (création/maj)
resource "keycloak_user" "user" {
  for_each       = var.manage_users ? var.users : {}
  realm_id       = var.realm
  username       = each.key
  email          = each.value.email
  enabled        = coalesce(try(each.value.enabled, null), true)
  email_verified = coalesce(try(each.value.email_verified, null), true)

  dynamic "initial_password" {
    for_each = try(each.value.initial_password, null) != null ? [1] : []
    content {
      value     = each.value.initial_password
      temporary = true
    }
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [
      first_name,
      last_name,
      email,
      attributes,
      initial_password,
    ]
  }

}

# Mode 2: on **lookup** des users existants (par NOM)
# (nécessite que le provider Keycloak expose data.keycloak_user ; sinon laissez manage_users=true)
data "keycloak_user" "existing" {
  for_each = var.manage_users ? {} : var.users
  realm_id = var.realm
  username = each.key
}

########################################
# Memberships (user -> groups) par NOM
########################################
locals {
  user_ids = merge(
    { for k, u in keycloak_user.user      : k => u.id },
    { for k, u in data.keycloak_user.existing : k => u.id }
  )
}

resource "keycloak_user_groups" "membership" {
  for_each = var.users

  realm_id = var.realm
  user_id  = local.user_ids[each.key]

  group_ids = [
    for g in each.value.groups :
    data.keycloak_group.by_name[g].id
  ]
}