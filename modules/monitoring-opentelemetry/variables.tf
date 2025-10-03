variable "namespace" {
  description = "Namespace Kubernetes ou déployer opentelemetry"
  type        = string
}

variable "receivers_dir" {
  description = "Dossier ou trouver les fichiers receivers"
  type        = string
}
variable "processors_dir" {
  description = "Dossier ou trouver les fichiers processors"
  type        = string
}
variable "exporters_dir" {
  description = "Dossier ou trouver les fichiers exporters"
  type        = string
}
variable "connectors_dir" {
  description = "Dossier ou trouver les fichiers connectors"
  type        = string
}

variable "extra_args" {
  description = "list of extra args parameters"
  type = set(string)
}

variable "labels" {
  description = "otel labels"
  type = map(string)
}

variable "replicas" {
  description = "replicas"
  type = number
}

variable "serviceAccountName" {
  description = "service account"
  type = string
}

variable "mode" {
  description = "mode de déploiement"
  type = string
}