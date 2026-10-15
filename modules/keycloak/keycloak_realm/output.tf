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

output "service_account_user_ids" {
  description = "Utilisateur technique des clients à compte de service (nom → id)."
  value = {
    for client_name, client_res in keycloak_openid_client.clients :
    client_name => client_res.service_account_user_id
    if client_res.service_accounts_enabled
  }
}

output "client_roles_ids" {
  description = "Rôles de client (<client>-<rôle> → id), cf. variable client_roles_ids du module keycloak_groups."
  value       = { for key, role in keycloak_role.client_roles : key => role.id }
}
