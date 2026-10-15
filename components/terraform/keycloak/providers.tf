terraform {
  required_version = ">= 1.7"

  required_providers {
    keycloak = {
      source  = "keycloak/keycloak"
      version = "5.9.0"
    }
  }
}

provider "keycloak" {
  url                      = var.keycloak_url
  realm                    = "master"
  client_id                = "admin-cli"
  username                 = var.keycloak_admin_username
  password                 = var.keycloak_admin_password
  tls_insecure_skip_verify = var.keycloak_tls_insecure
}
