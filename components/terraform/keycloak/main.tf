module "realm" {
  source = "../../../modules/keycloak/keycloak_realm"

  realm_conf = var.realm_conf
  clients    = var.clients
}

module "groups" {
  source = "../../../modules/keycloak/keycloak_groups"

  realm_id         = module.realm.realm_id
  clients          = module.realm.clients_output
  realm_roles_ids  = {}
  client_roles_ids = module.realm.client_roles_ids
  groups           = var.groups
}

module "users" {
  source = "../../../modules/keycloak/keycloak_users"

  realm        = module.realm.realm_id
  manage_users = true
  users = {
    for name, user in var.users :
    name => merge(user, { initial_password = lookup(var.initial_passwords, name, null) })
  }

  depends_on = [module.groups]
}
