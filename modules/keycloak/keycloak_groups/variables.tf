variable "realm_id" {
  description = "ID du Realm"
  type        = string
}

variable "clients" {
  description = "Mapping des clients (nom → ID)"
  type        = map(string)
}

variable "realm_roles_ids" {
  description = "Nom des realm roles → ID"
  type        = map(string)
}

variable "client_roles_ids" {
  description = "Nom des client roles → ID"
  type        = map(string)
}

variable "groups" {
  description = <<EOF
Liste plate des groupes Keycloak.

Exemple :
groups = [
  {
    name            = "platform"
    parent          = null
    realm_roles     = ["platform.readonly"]
    roles_by_client = { grafana = ["viewer"] }  # clé = client, valeur = rôles de ce client
  },
  {
    name         = "platform/admins"
    parent       = "platform"
    realm_roles  = ["platform.admin"]
  }
]
EOF
  type = list(object({
    name            = string
    parent          = string
    realm_roles     = optional(list(string), [])
    roles_by_client = optional(map(list(string)), {})
    attributes      = optional(map(string), {})
  }))
}
