variable "realm_id" {
  description = "Realm où les rôles doivent être créés"
  type        = string
}

variable "clients" {
  description = "Mapping des clients Keycloak existants (nom → ID)"
  type        = map(string) # client_name => client_id
}

variable "client_roles" {
  description = "Mapping de roles par client"
  type        = map(list(string)) # client_name => ["admin", "readonly"]
}
