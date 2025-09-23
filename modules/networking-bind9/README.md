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

  # Définition des zones
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

  # Service Bind9 classique
  service_name = "bind9-svc"
  service_type = "NodePort"
  service_port = 30053
  node_port    = 30053

  # Activation de dnsdist pour DNS-over-HTTPS
  dnsdist_enabled      = true
  dnsdist_image        = "powerdns/dnsdist-18:latest"
  dnsdist_port         = 443
  dnsdist_service_type = "NodePort"
  dnsdist_node_port    = 30443

  # Secret Kubernetes contenant ton certificat TLS
  # (généré avec SAN = IP du LB ou domaine associé)
  dnsdist_cert_secret  = "dnsdist-tls"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bind9_node_port"></a> [bind9\_node\_port](#input\_bind9\_node\_port) | Optional fixed nodePort value (only if service\_type=NodePort) | `number` | `null` | no |
| <a name="input_bind9_service_name"></a> [bind9\_service\_name](#input\_bind9\_service\_name) | Name of the Kubernetes Service | `string` | `"bind9-svc"` | no |
| <a name="input_bind9_service_port"></a> [bind9\_service\_port](#input\_bind9\_service\_port) | Port exposed by the Kubernetes Service | `number` | `53` | no |
| <a name="input_bind9_service_type"></a> [bind9\_service\_type](#input\_bind9\_service\_type) | Type of Kubernetes Service (ClusterIP, NodePort, LoadBalancer) | `string` | `"ClusterIP"` | no |
| <a name="input_bind9_zones"></a> [bind9\_zones](#input\_bind9\_zones) | Map des zones DNS à configurer.<br/>Chaque clé = nom de la zone (ex: my-domain.local).<br/>Chaque valeur contient :<br/>- zone\_file : chemin vers le fichier de zone (db.<zone>)<br/>- conf\_file : chemin vers le fichier de déclaration de la zone | <pre>map(object({<br/>    zone_file = string<br/>  }))</pre> | n/a | yes |
| <a name="input_bind_allow_query"></a> [bind\_allow\_query](#input\_bind\_allow\_query) | n/a | `list(string)` | <pre>[<br/>  "any"<br/>]</pre> | no |
| <a name="input_bind_allow_query_cache"></a> [bind\_allow\_query\_cache](#input\_bind\_allow\_query\_cache) | n/a | `list(string)` | <pre>[<br/>  "none"<br/>]</pre> | no |
| <a name="input_bind_custom_options_file"></a> [bind\_custom\_options\_file](#input\_bind\_custom\_options\_file) | Chemin vers un fichier nommé.conf.options custom. Si vide, les options sont utilisées. | `string` | `""` | no |
| <a name="input_bind_dnssec_validation"></a> [bind\_dnssec\_validation](#input\_bind\_dnssec\_validation) | n/a | `string` | `"no"` | no |
| <a name="input_bind_forwarders"></a> [bind\_forwarders](#input\_bind\_forwarders) | n/a | `list(string)` | `[]` | no |
| <a name="input_bind_listen_on_v6"></a> [bind\_listen\_on\_v6](#input\_bind\_listen\_on\_v6) | n/a | `bool` | `false` | no |
| <a name="input_bind_recursion"></a> [bind\_recursion](#input\_bind\_recursion) | n/a | `bool` | `false` | no |
| <a name="input_dnsdist_cert_secret"></a> [dnsdist\_cert\_secret](#input\_dnsdist\_cert\_secret) | Nom du secret Kubernetes contenant le certificat TLS (cert.pem + key.pem) | `string` | n/a | yes |
| <a name="input_dnsdist_check_resolve_dns"></a> [dnsdist\_check\_resolve\_dns](#input\_dnsdist\_check\_resolve\_dns) | Domain to check if dns downstream is up | `string` | `"localhost"` | no |
| <a name="input_dnsdist_enabled"></a> [dnsdist\_enabled](#input\_dnsdist\_enabled) | Activer ou non le proxy dnsdist devant Bind9 | `bool` | `true` | no |
| <a name="input_dnsdist_image"></a> [dnsdist\_image](#input\_dnsdist\_image) | Image Docker de dnsdist | `string` | `"powerdns/dnsdist-18:latest"` | no |
| <a name="input_dnsdist_node_port"></a> [dnsdist\_node\_port](#input\_dnsdist\_node\_port) | NodePort si dnsdist\_service\_type=NodePort | `number` | `null` | no |
| <a name="input_dnsdist_port"></a> [dnsdist\_port](#input\_dnsdist\_port) | Port exposé pour DoH | `number` | `443` | no |
| <a name="input_dnsdist_service_name"></a> [dnsdist\_service\_name](#input\_dnsdist\_service\_name) | Nom du service dnsdist | `string` | `"dnsdist-svc"` | no |
| <a name="input_dnsdist_service_type"></a> [dnsdist\_service\_type](#input\_dnsdist\_service\_type) | Type du service dnsdist (ClusterIP, NodePort, LoadBalancer) | `string` | `"NodePort"` | no |
| <a name="input_dnsdist_svc_port"></a> [dnsdist\_svc\_port](#input\_dnsdist\_svc\_port) | Port exposé pour le service | `number` | `443` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace Kubernetes où déployer Bind9 | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bind9_service"></a> [bind9\_service](#output\_bind9\_service) | Infos sur le service Bind9 |