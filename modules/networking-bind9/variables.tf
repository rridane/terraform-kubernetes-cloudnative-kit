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
