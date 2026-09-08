output "client_roles_ids" {
  description = "Mapping client-role_name → role_id"
  value = {
    for name, role in keycloak_role.client_roles :
    name => role.id
  }
}
