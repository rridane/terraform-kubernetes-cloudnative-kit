#!/usr/bin/env bash
set -euo pipefail

# Init + plan
terraform init -input=false
terraform plan -out=plans/tfplan

# Export en JSON
terraform show -json plans/tfplan > plans/plan.json

echo "✅ Plan généré dans tests/plan.json"
