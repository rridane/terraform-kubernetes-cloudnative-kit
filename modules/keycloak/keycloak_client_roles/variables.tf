variable "realm_id" {
  description = "Realm où les rôles doivent être créés"
  type        = string
}

variable "clients" {
  description = "Mapping des clients Keycloak existants (nom → ID)"
  type        = map(string) # client_name => client_id
}

variable "roles_by_client" {
  description = "Rôles à créer, indexés par client : clé = nom du client, valeur = noms des rôles de ce client. Ex: { grafana = [\"grafana-admin\", \"grafana-editor\"] }"
  type        = map(list(string)) # client_name => ["admin", "readonly"]
}
