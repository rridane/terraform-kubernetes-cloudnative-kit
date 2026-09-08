output "realm_roles_ids" {
  description = "Mapping realm_role_name → role_id"
  value = {
    for name, role in keycloak_role.realm_roles:
    name => role.id
  }
}
