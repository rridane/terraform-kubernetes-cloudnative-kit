locals {
  groups_mapper_enabled = {
    for client_name, client_conf in var.clients :
    client_name => (
    client_conf.add_groups_to.id_token ||
    client_conf.add_groups_to.access_token ||
    client_conf.add_groups_to.userinfo
    )
  }
  realm_roles_mapper_enabled = {
    for client_name, client_conf in var.clients :
    client_name => (
    client_conf.add_realm_roles_to.id_token ||
    client_conf.add_realm_roles_to.access_token ||
    client_conf.add_realm_roles_to.userinfo
    )
  }
  client_roles_mapper_enabled = {
    for client_name, client_conf in var.clients :
    client_name => (
    client_conf.add_client_roles_to.id_token ||
    client_conf.add_client_roles_to.access_token ||
    client_conf.add_client_roles_to.userinfo
    )
  }
}

resource "keycloak_openid_group_membership_protocol_mapper" "groups" {
  for_each = {
    for client_name, client_conf in var.clients : client_name => client_conf
    if local.groups_mapper_enabled[client_name]
  }

  realm_id  = keycloak_realm.this.id
  client_id = keycloak_openid_client.clients[each.key].id
  name      = "${each.key}-groups"

  claim_name = each.value.groups_claim

  add_to_id_token     = each.value.add_groups_to.id_token
  add_to_access_token = each.value.add_groups_to.access_token
  add_to_userinfo     = each.value.add_groups_to.userinfo
}

resource "keycloak_openid_user_realm_role_protocol_mapper" "realm_roles" {
  for_each = {
    for client_name, client_conf in var.clients : client_name => client_conf
    if local.realm_roles_mapper_enabled[client_name]
  }

  realm_id  = keycloak_realm.this.id
  client_id = keycloak_openid_client.clients[each.key].id
  name      = "${each.key}-realm-roles"

  add_to_id_token     = each.value.add_realm_roles_to.id_token
  add_to_access_token = each.value.add_realm_roles_to.access_token
  add_to_userinfo     = each.value.add_realm_roles_to.userinfo
}

resource "keycloak_openid_user_client_role_protocol_mapper" "client_roles" {
  for_each = {
    for client_name, client_conf in var.clients : client_name => client_conf
    if local.client_roles_mapper_enabled[client_name]
  }

  realm_id  = keycloak_realm.this.id
  client_id = keycloak_openid_client.clients[each.key].id
  name      = "${each.key}-client-roles"

  add_to_id_token     = each.value.add_client_roles_to.id_token
  add_to_access_token = each.value.add_client_roles_to.access_token
  add_to_userinfo     = each.value.add_client_roles_to.userinfo
}
