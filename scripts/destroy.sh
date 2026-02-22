#!/usr/bin/env bash
set -euo pipefail

RG="rg-aks-lab"

echo "==> Deleting resource group (cost guardrail)"
az group delete -n "$RG" --yes --no-wait