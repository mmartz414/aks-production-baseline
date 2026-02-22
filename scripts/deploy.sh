#!/usr/bin/env bash
set -euo pipefail

# ===== Config =====
RG="rg-aks-lab"
LOC="centralus"
BICEP_FILE="infra/main.bicep"
PARAM_FILE="infra/params.dev.json"

echo "==> Creating resource group"
az group create -n "$RG" -l "$LOC" >/dev/null

echo "==> Deploying Bicep"
az deployment group create \
  -g "$RG" \
  -f "$BICEP_FILE" \
  -p "$PARAM_FILE"

AKS_NAME=$(jq -r '.parameters.aksName.value' "$PARAM_FILE")

echo "==> Getting AKS credentials"
az aks get-credentials -g "$RG" -n "$AKS_NAME" --overwrite-existing

echo "==> Cluster nodes"
kubectl get nodes -o wide

echo "==> Base deployment ready"
echo "Next steps:"
echo "  kubectl apply -f k8s/hello.yaml"
echo "  kubectl apply -f k8s/hpa.yaml"
echo "  kubectl apply -f k8s/load-generator.yaml"