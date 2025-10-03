# 📖 Module Terraform — cert-manager-certificate

Ce module Terraform crée une ressource **`cert-manager.io/v1 Certificate`** dans Kubernetes.  
Il permet de générer un certificat TLS à partir d’un **Issuer** ou **ClusterIssuer** déjà configuré (par ex. Vault, ACME, etc.) et retourne le `Secret` TLS associé.

---

## 🚀 Exemple d’utilisation

```hcl
module "certificates" {
  source    = "rridane/cloudnative-kit/kubernetes//modules/security-cer--manager"

  # Nom de la ressource Certificate
  name       = "mon-domain-cert"

  # Namespace Kubernetes
  namespace  = "monnamespace"

  # Nom commun (optionnel, SAN prime toujours)
  common_name = "mon.domain.dev"

  # SAN (Subject Alternative Names) → inclut l'IP ou les DNS
  dns_names = [
    "domain.dev",
    "sub.mon.domain.dev"
  ]

  # Issuer ou ClusterIssuer
  issuer_name = "vault-issuer-domain-dev"
  issuer_kind = "ClusterIssuer"

  # Nom du Secret TLS qui contiendra cert + clé privée
  secret_name = "mon-domain-tls"
}

module "bind9_zones" {
  source    = "rridane/cloudnative-kit/kubernetes//modules/networking-bind9"
  version   = "0.2.27"
  namespace = "bind9"
  bind9_zones = {
    "domain.dev" = {
      zone_file = "${path.cwd}/config/domain.dev"
      conf_file = "${path.cwd}/config/domain.dev.conf"
    }
    "sub.domain.dev" = {
      zone_file = "${path.cwd}/config/sub.domain.dev"
    }
  }
  bind9_service_name = "bind9-svc"
  bind9_service_type = "ClusterIP"
  bind9_service_port = 53
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