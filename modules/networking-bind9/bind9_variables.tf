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
