variable "namespace" {
  description = "Namespace Kubernetes où déployer Bind9"
  type        = string
}

variable "zones" {
  description = <<EOT
Map des zones DNS à configurer.
Chaque clé = nom de la zone (ex: my-domain.local).
Chaque valeur contient :
- zone_file : chemin vers le fichier de zone (db.<zone>)
- conf_file : chemin vers le fichier de déclaration de la zone
EOT

  type = map(object({
    zone_file = string
  }))
}

variable "service_type" {
  description = "Type of Kubernetes Service (ClusterIP, NodePort, LoadBalancer)"
  type        = string
  default     = "ClusterIP"
}

variable "service_port" {
  description = "Port exposed by the Kubernetes Service"
  type        = number
  default     = 53
}

variable "node_port" {
  description = "Optional fixed nodePort value (only if service_type=NodePort)"
  type        = number
  default     = null
}

variable "service_name" {
  description = "Name of the Kubernetes Service"
  type        = string
  default     = "bind9-svc"
}


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

variable "check_resolve_dns" {
  type        = string
  default     = "localhost"
  description = "Domain to check if dns downstream is up"
}
