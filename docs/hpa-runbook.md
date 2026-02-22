# HPA Runbook (AKS)

## Prerequisites
- Metrics available (`kubectl top nodes` works)
- Deployment has CPU requests/limits

## Deploy
1. Apply base app:
   - `kubectl apply -f k8s/hello.yaml`
2. Apply ingress (if needed):
   - `kubectl apply -f k8s/ingress.yaml`
3. Apply HPA:
   - `kubectl apply -f k8s/hpa.yaml`

## Validate
- `kubectl get hpa`
- `kubectl describe hpa hello-hpa`

## Generate load (temporary)
- `kubectl apply -f k8s/load-generator.yaml`
- Watch:
  - `kubectl get pods -w`
  - `kubectl get hpa -w`

## Cleanup
- `kubectl delete -f k8s/load-generator.yaml`
- Optional teardown:
  - `az group delete -n rg-aks-lab --yes --no-wait`