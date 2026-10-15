mock_provider "keycloak" {}

variables {
  realm_conf = { display_name = "test" }
  clients    = jsondecode(file("tests/fixtures/clients.json"))
}

run "schema_matches_variable_type" {
  command = plan

  assert {
    condition     = sort(keys(var.clients["worker"])) == sort(keys(jsondecode(file("schemas/client.schema.json")).properties))
    error_message = "Attributs de clients et schemas/client.schema.json divergent."
  }

  assert {
    condition     = sort(keys(var.clients["worker"].client_roles_mapper)) == sort(keys(jsondecode(file("schemas/client.schema.json")).properties.client_roles_mapper.properties))
    error_message = "client_roles_mapper : type et schéma divergent."
  }

  assert {
    condition     = sort(keys(var.clients["worker"].audience_mapper)) == sort(keys(jsondecode(file("schemas/client.schema.json")).properties.audience_mapper.properties))
    error_message = "audience_mapper : type et schéma divergent."
  }

  assert {
    condition     = sort(keys(var.clients["worker"].add_groups_to)) == sort(keys(jsondecode(file("schemas/client.schema.json")).definitions.token_targets.properties))
    error_message = "token_targets : type et schéma divergent."
  }
}

run "roles_and_service_account_roles" {
  assert {
    condition     = sort(keys(keycloak_role.client_roles)) == tolist(["resource-admin", "resource-writer"])
    error_message = "Rôles de client inattendus."
  }

  assert {
    condition     = sort(keys(keycloak_openid_client_service_account_role.service_account_roles)) == tolist(["worker-resource-writer"])
    error_message = "Rôles de compte de service inattendus."
  }

  assert {
    condition = (
      keycloak_openid_client_service_account_role.service_account_roles["worker-resource-writer"].service_account_user_id == keycloak_openid_client.clients["worker"].service_account_user_id &&
      keycloak_openid_client_service_account_role.service_account_roles["worker-resource-writer"].client_id == keycloak_openid_client.clients["resource"].id &&
      keycloak_openid_client_service_account_role.service_account_roles["worker-resource-writer"].role == "writer"
    )
    error_message = "Rôle writer de resource non attribué au compte de service de worker."
  }
}

run "rejects_undeclared_role" {
  command = plan

  variables {
    clients = merge(jsondecode(file("tests/fixtures/clients.json")), {
      worker = merge(jsondecode(file("tests/fixtures/clients.json")).worker, { service_account_roles = { resource = ["ghost"] } })
    })
  }

  expect_failures = [var.clients]
}

run "rejects_roles_without_service_account" {
  command = plan

  variables {
    clients = merge(jsondecode(file("tests/fixtures/clients.json")), {
      worker = merge(jsondecode(file("tests/fixtures/clients.json")).worker, { service_accounts_enabled = false })
    })
  }

  expect_failures = [var.clients]
}
