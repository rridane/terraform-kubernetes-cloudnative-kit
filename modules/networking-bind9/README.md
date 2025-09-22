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
