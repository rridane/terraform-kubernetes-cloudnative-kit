variable "keycloak_url" {
  description = "URL publique de Keycloak, joignable depuis le poste qui applique."
  type        = string
}

variable "keycloak_admin_username" {
  description = "Admin du realm master (TF_VAR_keycloak_admin_username)."
  type        = string
  sensitive   = true
}

variable "keycloak_admin_password" {
  description = "Mot de passe de l'admin du realm master (TF_VAR_keycloak_admin_password)."
  type        = string
  sensitive   = true
}

variable "keycloak_tls_insecure" {
  description = "Désactive la vérification TLS."
  type        = bool
  default     = false
}

variable "realm_conf" {
  description = "Configuration du realm, cf. variable realm_conf du module keycloak_realm."
  type        = any
}

variable "clients" {
  description = "Clients du realm (client_id → client), cf. modules/keycloak/keycloak_realm/schemas/client.schema.json."
  type        = any
  default     = {}
}

variable "groups" {
  description = "Groupes du realm, cf. variable groups du module keycloak_groups."
  type        = any
  default     = []
}

variable "users" {
  description = "Utilisateurs du realm, sans mot de passe, cf. variable users du module keycloak_users."
  type        = any
  default     = {}
}

variable "initial_passwords" {
  description = "Mots de passe initiaux temporaires (utilisateur → mot de passe), via TF_VAR_initial_passwords."
  type        = map(string)
  default     = {}
  sensitive   = true
}
