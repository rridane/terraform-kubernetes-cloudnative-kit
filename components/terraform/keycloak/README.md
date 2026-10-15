<!-- BEGIN_TF_DOCS -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_clients"></a> [clients](#input\_clients) | Clients du realm (client\_id → client), cf. modules/keycloak/keycloak\_realm/schemas/client.schema.json. | `any` | `{}` | no |
| <a name="input_groups"></a> [groups](#input\_groups) | Groupes du realm, cf. variable groups du module keycloak\_groups. | `any` | `[]` | no |
| <a name="input_initial_passwords"></a> [initial\_passwords](#input\_initial\_passwords) | Mots de passe initiaux temporaires (utilisateur → mot de passe), via TF\_VAR\_initial\_passwords. | `map(string)` | `{}` | no |
| <a name="input_keycloak_admin_password"></a> [keycloak\_admin\_password](#input\_keycloak\_admin\_password) | Mot de passe de l'admin du realm master (TF\_VAR\_keycloak\_admin\_password). | `string` | n/a | yes |
| <a name="input_keycloak_admin_username"></a> [keycloak\_admin\_username](#input\_keycloak\_admin\_username) | Admin du realm master (TF\_VAR\_keycloak\_admin\_username). | `string` | n/a | yes |
| <a name="input_keycloak_tls_insecure"></a> [keycloak\_tls\_insecure](#input\_keycloak\_tls\_insecure) | Désactive la vérification TLS. | `bool` | `false` | no |
| <a name="input_keycloak_url"></a> [keycloak\_url](#input\_keycloak\_url) | URL publique de Keycloak, joignable depuis le poste qui applique. | `string` | n/a | yes |
| <a name="input_realm_conf"></a> [realm\_conf](#input\_realm\_conf) | Configuration du realm, cf. variable realm\_conf du module keycloak\_realm. | `any` | n/a | yes |
| <a name="input_users"></a> [users](#input\_users) | Utilisateurs du realm, sans mot de passe, cf. variable users du module keycloak\_users. | `any` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_client_secrets"></a> [client\_secrets](#output\_client\_secrets) | Secrets des clients CONFIDENTIAL (client\_id → secret). |
| <a name="output_clients"></a> [clients](#output\_clients) | Clients (client\_id → id). |
| <a name="output_oidc_issuer_url"></a> [oidc\_issuer\_url](#output\_oidc\_issuer\_url) | Issuer OIDC du realm. |
| <a name="output_realm"></a> [realm](#output\_realm) | Nom du realm. |
<!-- END_TF_DOCS -->