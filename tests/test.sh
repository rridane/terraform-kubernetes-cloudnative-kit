#!/usr/bin/env bash

set -euo pipefail

conftest test plans/plan.json --policy policies/policies.rego
