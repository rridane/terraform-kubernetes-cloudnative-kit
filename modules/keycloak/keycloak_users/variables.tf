variable "realm" {
  description = "Nom du realm où créer/binder les users"
  type        = string
}

variable "users" {
  description = <<EOT
Map d'utilisateurs à gérer. Chaque entrée a:
- email
- groups : liste de *noms* de groupes (ex: 'k8s:all:pod_manage')
- enabled/email_verified (optionnels)
- initial_password (optionnel; si non fourni, pas de reset)
EOT
  type = map(object({
    email            = string
    groups           = list(string)
    enabled          = optional(bool, true)
    email_verified   = optional(bool, true)
    initial_password = optional(string, null)
  }))
}

# Si true : le module **crée**/administre les users (recommandé).
# Si false : le module suppose que les users existent déjà et utilise un data source pour les retrouver par username.
variable "manage_users" {
  type        = bool
  default     = true
  description = "Créer/manager les users (true) ou seulement binder des users existants (false)"
}