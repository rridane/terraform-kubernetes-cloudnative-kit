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
