output "realm" {
  description = "Nom du realm."
  value       = module.realm.realm_id
}

output "oidc_issuer_url" {
  description = "Issuer OIDC du realm."
  value       = "${var.keycloak_url}/realms/${module.realm.realm_id}"
}

output "clients" {
  description = "Clients (client_id → id)."
  value       = module.realm.clients_output
}

output "client_secrets" {
  description = "Secrets des clients CONFIDENTIAL (client_id → secret)."
  value       = module.realm.client_secrets
  sensitive   = true
}
