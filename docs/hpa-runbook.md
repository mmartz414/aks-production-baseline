# HPA Runbook (AKS)

## Purpose
Validate horizontal autoscaling behavior for the hello workload.

## Prerequisites
- AKS cluster reachable
- Metrics available (`kubectl top nodes`)
- Deployment defines CPU requests/limits

## Deploy HPA
kubectl apply -f k8s/hpa.yaml

## Validate
kubectl get hpa
kubectl describe hpa hello-hpa

## Generate load
kubectl apply -f k8s/load-generator.yaml

## Observe scaling
kubectl get pods -w
kubectl get hpa -w

## Cleanup
kubectl delete -f k8s/load-generator.yaml