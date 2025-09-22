variable "name" {
  description = "Nom du certificat (ressource Certificate et Secret)"
  type        = string
}

variable "namespace" {
  description = "Namespace Kubernetes où créer le certificat"
  type        = string
}

variable "common_name" {
  description = "Nom commun (CN) du certificat"
  type        = string
}

variable "dns_names" {
  description = "Liste des SAN (Subject Alternative Names)"
  type        = list(string)
}

variable "issuer_name" {
  description = "Nom du ClusterIssuer/Issuer"
  type        = string
}

variable "issuer_kind" {
  description = "Kind de l'issuer (Issuer ou ClusterIssuer)"
  type        = string
  default     = "ClusterIssuer"
}

variable "secret_name" {
  description = "Nom du secret TLS où sera stocké le certificat"
  type        = string
}
