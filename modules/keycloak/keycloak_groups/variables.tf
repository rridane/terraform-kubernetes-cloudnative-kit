
variable "realm_id" {
  description = "Realm où créer les groupes"
  type        = string
}

variable "clients" {
  description = "Mapping des clients (nom → ID)"
  type        = map(string)
}

variable "groups" {
  description = <<EOF
Arborescence des groupes.
Structure :
groups = {
  platform = {
    attributes   = { foo = "bar" }
    realm_roles  = ["roleA"]
    client_roles = {
      grafana = ["viewer"]
      argocd  = ["readonly"]
    }
    subgroups = {
      admins = {
        realm_roles = ["roleB"]
      }
    }
  }
}
EOF

  type = map(object({
    attributes    = optional(map(string), {})
    realm_roles   = optional(list(string), [])
    client_roles  = optional(map(list(string)), {})
    subgroups     = optional(map(object({
      attributes    = optional(map(string), {})
      realm_roles   = optional(list(string), [])
      client_roles  = optional(map(list(string)), {})
    })), {})
  }))
}
