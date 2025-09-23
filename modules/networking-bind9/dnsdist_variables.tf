variable "dnsdist_enabled" {
  type        = bool
  default     = true
  description = "Activer ou non le proxy dnsdist devant Bind9"
}

variable "dnsdist_image" {
  type        = string
  default     = "powerdns/dnsdist-18:latest"
  description = "Image Docker de dnsdist"
}

variable "dnsdist_port" {
  type        = number
  default     = 443
  description = "Port exposé pour DoH"
}

variable "dnsdist_svc_port" {
  type        = number
  default     = 443
  description = "Port exposé pour le service"
}

variable "dnsdist_cert_secret" {
  type        = string
  description = "Nom du secret Kubernetes contenant le certificat TLS (cert.pem + key.pem)"
}

variable "dnsdist_service_type" {
  type        = string
  default     = "NodePort"
  description = "Type du service dnsdist (ClusterIP, NodePort, LoadBalancer)"
}

variable "dnsdist_node_port" {
  type        = number
  default     = null
  description = "NodePort si dnsdist_service_type=NodePort"
}

variable "dnsdist_service_name" {
  type        = string
  default     = "dnsdist-svc"
  description = "Nom du service dnsdist"
}

variable "dnsdist_check_resolve_dns" {
  type        = string
  default     = "localhost"
  description = "Domain to check if dns downstream is up"
}

