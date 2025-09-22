# 📖 Module Terraform — cert-manager-certificate

Ce module Terraform crée une ressource **`cert-manager.io/v1 Certificate`** dans Kubernetes.  
Il permet de générer un certificat TLS à partir d’un **Issuer** ou **ClusterIssuer** déjà configuré (par ex. Vault, ACME, etc.) et retourne le `Secret` TLS associé.

---

## 🚀 Exemple d’utilisation

```hcl
module "dnsdist_cert" {
  source     = "./terraform-modules/cert-manager-certificate"

  # Nom de la ressource Certificate
  name       = "dnsdist-cert"

  # Namespace Kubernetes
  namespace  = "system"

  # Nom commun (optionnel, SAN prime toujours)
  common_name = "10.33.250.16"

  # SAN (Subject Alternative Names) → inclut l'IP ou les DNS
  dns_names = [
    "10.33.250.16",
    "domain.dev",
    "sub.domain.dev"
  ]

  # Issuer ou ClusterIssuer
  issuer_name = "vault-issuer-domain-dev"
  issuer_kind = "ClusterIssuer"

  # Nom du Secret TLS qui contiendra cert + clé privée
  secret_name = "dnsdist-tls"
}

# Exemple d’utilisation avec dnsdist
module "bind9" {
  source    = "./terraform-modules/bind9"
  namespace = "system"

  zones = {
    "domain.dev" = {
      zone_file = "${path.cwd}/zones/domain.dev/db.domain.dev"
      conf_file = "${path.cwd}/zones/domain.dev/zone.conf.tmpl"
    }
  }

  service_name         = "bind9-svc"
  service_type         = "NodePort"
  service_port         = 30053
  node_port            = 30053

  dnsdist_enabled      = true
  dnsdist_port         = 443
  dnsdist_service_type = "NodePort"
  dnsdist_node_port    = 30443

  # On récupère directement le Secret généré par cert-manager
  dnsdist_cert_secret  = module.dnsdist_cert.secret_name
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_common_name"></a> [common\_name](#input\_common\_name) | Nom commun (CN) du certificat | `string` | n/a | yes |
| <a name="input_dns_names"></a> [dns\_names](#input\_dns\_names) | Liste des SAN (Subject Alternative Names) | `list(string)` | n/a | yes |
| <a name="input_issuer_kind"></a> [issuer\_kind](#input\_issuer\_kind) | Kind de l'issuer (Issuer ou ClusterIssuer) | `string` | `"ClusterIssuer"` | no |
| <a name="input_issuer_name"></a> [issuer\_name](#input\_issuer\_name) | Nom du ClusterIssuer/Issuer | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Nom du certificat (ressource Certificate et Secret) | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace Kubernetes où créer le certificat | `string` | n/a | yes |
| <a name="input_secret_name"></a> [secret\_name](#input\_secret\_name) | Nom du secret TLS où sera stocké le certificat | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_secret_name"></a> [secret\_name](#output\_secret\_name) | Nom du Secret TLS généré par cert-manager |