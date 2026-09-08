output "realm_id" {
  description = "ID du realm créé"
  value       = keycloak_realm.realm.id
}

output "clients_output" {
  description = "Mapping des clients Keycloak (nom → client_id)"
  value = {
    for client_name, client_res in keycloak_openid_client.clients :
    client_name => client_res.id
  }
}

output "client_secrets" {
  description = "Secrets des clients CONFIDENTIAL (nom → secret). Chaîne vide pour les clients PUBLIC."
  sensitive   = true
  value = {
    for client_name, client_res in keycloak_openid_client.clients :
    client_name => client_res.client_secret
  }
}
