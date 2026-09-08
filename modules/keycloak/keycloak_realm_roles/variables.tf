variable "realm_id" {
  description = "ID du realm où créer les rôles"
  type        = string
}

variable "realm_roles" {
  description = "Liste des realm roles à créer"
  type        = list(string)
}
