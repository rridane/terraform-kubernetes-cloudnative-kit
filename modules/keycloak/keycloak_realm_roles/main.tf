resource "keycloak_role" "realm_roles" {
  for_each = toset(var.realm_roles)

  realm_id = var.realm_id
  name     = each.key
}
