# Bind10 Terraform Module

Ce module déploie un serveur **BIND9** dans Kubernetes avec des zones configurées via ConfigMaps.

## 🔧 Variables

- `namespace` : Namespace où déployer Bind9
- `zones` : Map des zones DNS

## 📂 Structure attendue

```yaml
zones/
├── my-domain.local/
│ ├── db.my-zone.tld
│ └── zone.conf.tmpl
└── example.com/
├── db.example.com
└── zone.conf.tmpl
```

## 🚀 Exemple d’utilisation

```hcl
module "bind9" {
  source    = "./terraform-modules/bind9"
  namespace = "system"

  zones = {
    "my-domain.local" = {
      zone_file = "${path.cwd}/zones/my-zone.tld/my-zone.tld"
      conf_file = "${path.cwd}/zones/my-zone.tld/zone.conf.tmpl"
    }
    "example.com" = {
      zone_file = "${path.cwd}/zones/example.com/db.example.com"
      conf_file = "${path.cwd}/zones/example.com/zone.conf.tmpl"
    }
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace Kubernetes où déployer Bind9 | `string` | n/a | yes |
| <a name="input_node_port"></a> [node\_port](#input\_node\_port) | Optional fixed nodePort value (only if service\_type=NodePort) | `number` | `null` | no |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | Name of the Kubernetes Service | `string` | `"bind9-svc"` | no |
| <a name="input_service_port"></a> [service\_port](#input\_service\_port) | Port exposed by the Kubernetes Service | `number` | `53` | no |
| <a name="input_service_type"></a> [service\_type](#input\_service\_type) | Type of Kubernetes Service (ClusterIP, NodePort, LoadBalancer) | `string` | `"ClusterIP"` | no |
| <a name="input_zones"></a> [zones](#input\_zones) | Map des zones DNS à configurer.<br/>Chaque clé = nom de la zone (ex: my-domain.local).<br/>Chaque valeur contient :<br/>- zone\_file : chemin vers le fichier de zone (db.<zone>)<br/>- conf\_file : chemin vers le fichier de déclaration de la zone | <pre>map(object({<br/>    zone_file = string<br/>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bind9_service"></a> [bind9\_service](#output\_bind9\_service) | Infos sur le service Bind9 |