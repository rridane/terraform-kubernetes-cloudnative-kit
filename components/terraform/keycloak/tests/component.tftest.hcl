mock_provider "keycloak" {}

variables {
  keycloak_url            = "https://auth.example.com"
  keycloak_admin_username = "admin"
  keycloak_admin_password = "admin"
  realm_conf              = { display_name = "test" }

  clients = {
    resource = {
      name          = "Resource"
      access_type   = "CONFIDENTIAL"
      redirect_uris = []
      roles         = ["admin"]
    }
  }

  groups = [
    { name = "admins", parent = null, roles_by_client = { resource = ["admin"] } },
  ]

  users = {
    alice = { email = "alice@example.com", groups = ["admins"] }
    bob   = { email = "bob@example.com", groups = [] }
  }

  initial_passwords = { alice = "temporary" }
}

run "plans_realm_groups_and_users" {
  command = plan
}
