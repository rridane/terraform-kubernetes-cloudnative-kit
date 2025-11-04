# Génération des policies Vault
data "vault_policy_document" "generated" {
  for_each = {
    for p in local.policies_list : p["name"] => p
  }

  dynamic "rule" {
    for_each = [each.value]
    content {
      path         = rule.value["path"]
      capabilities = rule.value["capabilities"]
      description  = rule.value["description"]
    }
  }
}

resource "vault_policy" "generated" {
  for_each = data.vault_policy_document.generated

  name   = each.key
  policy = each.value.hcl
}

