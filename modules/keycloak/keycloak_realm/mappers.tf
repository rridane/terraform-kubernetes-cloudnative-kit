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
    try(client_conf.client_roles_mapper.enabled, false)
    )
  }
  audience_mapper_enabled = {
    for client_name, client_conf in var.clients :
    client_name => (
    try(client_conf.audience_mapper.enabled, false)
    )
  }

}

resource "keycloak_openid_group_membership_protocol_mapper" "groups" {
  for_each = {
    for client_name, client_conf in var.clients : client_name => client_conf
    if local.groups_mapper_enabled[client_name]
  }

  realm_id  = keycloak_realm.realm.id
  client_id = keycloak_openid_client.clients[each.key].id
  name      = "${each.key}-groups"

  claim_name = each.value.groups_claim

  add_to_id_token     = each.value.add_groups_to.id_token
  add_to_access_token = each.value.add_groups_to.access_token
  add_to_userinfo     = each.value.add_groups_to.userinfo
  full_path = false
}

resource "keycloak_openid_user_realm_role_protocol_mapper" "realm_roles" {
  for_each = {
    for client_name, client_conf in var.clients : client_name => client_conf
    if local.realm_roles_mapper_enabled[client_name]
  }

  realm_id  = keycloak_realm.realm.id
  client_id = keycloak_openid_client.clients[each.key].id
  name      = "${each.key}-realm-roles"

  claim_name = each.value.realm_roles_claim

  add_to_id_token     = each.value.add_realm_roles_to.id_token
  add_to_access_token = each.value.add_realm_roles_to.access_token
  add_to_userinfo     = each.value.add_realm_roles_to.userinfo
}

resource "keycloak_openid_user_client_role_protocol_mapper" "client_roles" {
  for_each = {
    for client_name, client_conf in var.clients :
    client_name => client_conf.client_roles_mapper
    if local.client_roles_mapper_enabled[client_name]
  }

  realm_id  = keycloak_realm.realm.id
  client_id = keycloak_openid_client.clients[each.key].id

  name = "${each.key}-client-roles"

  # Le claim où ArgoCD va lire
  claim_name = each.value.claim_name
  claim_value_type = "String"

  # Le préfixe (ex: "argocd-")
  client_role_prefix = each.value.role_prefix

  # Important pour plusieurs rôles !
  multivalued = each.value.multivalued

  # Où mettre les infos
  add_to_id_token     = each.value.add_to_id_token
  add_to_access_token = each.value.add_to_access_token
  add_to_userinfo     = each.value.add_to_userinfo

  depends_on = [
    keycloak_openid_client.clients
  ]
}

resource "keycloak_openid_audience_protocol_mapper" "audience" {
  for_each = {
    for client_name, client_conf in var.clients :
    client_name => client_conf.audience_mapper
    if local.audience_mapper_enabled[client_name]
  }

  realm_id  = keycloak_realm.realm.id
  client_id = keycloak_openid_client.clients[each.key].id

  name = "${each.key}-audience"

  # Par défaut, on ajoute le client_id du client lui-même dans l'aud du token.
  # Surchargeable si on veut pointer vers un autre client (cas rare).
  included_client_audience = coalesce(each.value.included_client_audience, each.key)

  add_to_id_token     = each.value.add_to_id_token
  add_to_access_token = each.value.add_to_access_token

  depends_on = [
    keycloak_openid_client.clients
  ]
}

