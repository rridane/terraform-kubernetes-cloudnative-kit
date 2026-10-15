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

variable "service_account_user_ids" {
  description = "Utilisateur technique des comptes de service (nom du client → id), cf. output du module keycloak_realm."
  type        = map(string)
  default     = {}
}

variable "service_account_roles" {
  description = "Rôles de client attribués aux comptes de service : compte → client → rôles. Ex: { spans-extractor = { polaris = [\"polaris-lake-writer\"] } }"
  type        = map(map(list(string)))
  default     = {}
}
