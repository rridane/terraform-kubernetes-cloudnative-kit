variable "namespace" {
  description = "Namespace Kubernetes où déployer Bind9"
  type        = string
}

### dnsdist variables ###

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


#### Bind9 variables ####

variable "bind9_zones" {
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

variable "bind9_service_type" {
  description = "Type of Kubernetes Service (ClusterIP, NodePort, LoadBalancer)"
  type        = string
  default     = "ClusterIP"
}

variable "bind9_service_port" {
  description = "Port exposed by the Kubernetes Service"
  type        = number
  default     = 53
}

variable "bind9_node_port" {
  description = "Optional fixed nodePort value (only if service_type=NodePort)"
  type        = number
  default     = null
}

variable "bind9_service_name" {
  description = "Name of the Kubernetes Service"
  type        = string
  default     = "bind9-svc"
}

variable "bind_recursion" {
  type    = bool
  default = false
}

variable "bind_allow_query" {
  type    = list(string)
  default = ["any"]
}

variable "bind_allow_query_cache" {
  type    = list(string)
  default = ["none"]
}

variable "bind_forwarders" {
  type    = list(string)
  default = []
}

variable "bind_listen_on_v6" {
  type    = bool
  default = false
}

variable "bind_dnssec_validation" {
  type    = string
  default = "no"
}

variable "bind_custom_options_file" {
  type    = string
  default = ""
  description = "Chemin vers un fichier nommé.conf.options custom. Si vide, les options sont utilisées."
}
