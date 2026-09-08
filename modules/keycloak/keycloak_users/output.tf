output "user_ids" {
  value       = local.user_ids
  description = "IDs des utilisateurs gérés ou résolus"
}

output "memberships_applied" {
  value       = { for k, v in keycloak_user_groups.membership : k => v.group_ids }
  description = "Groups IDs appliqués par utilisateur"
  sensitive   = true
}
