# AKS Production Baseline (Budget Lab)

## Overview
Production-style Azure Kubernetes Service deployment built with cost guardrails.

## Key Features
- AKS with managed identity
- Azure Container Registry integration
- NGINX ingress
- Cost-controlled lab pattern (deploy → validate → destroy)

## Architecture
```mermaid
flowchart LR
  subgraph External
    U[User / Browser]
  end

  subgraph Azure
    PIP[Public IP]
    ALB[Azure Load Balancer<br/>(provisioned by NGINX Ingress)]
  end

  subgraph AKS[AKS Cluster]
    subgraph IngressNS[Namespace: ingress-nginx]
      NGINX[NGINX Ingress Controller]
    end

    subgraph AppNS[Namespace: default]
      SVC[Service: hello (ClusterIP)]
      POD[Pod: hello<br/>nginxdemos/hello]
    end
  end

  subgraph ACRZone[Azure Container Registry]
    ACR[ACR]
  end

  U --> PIP
  PIP --> ALB
  ALB --> NGINX
  NGINX --> SVC
  SVC --> POD
  AKS -->|Image Pull| ACR

  **Cost guardrail:** This environment is deployed only during lab sessions and fully removed afterward (`az group delete`) to prevent ongoing compute and load balancer charges.

## Cost Strategy
Cluster is deployed only during lab sessions and fully removed afterward to minimize spend.

## What this demonstrates
- AKS cluster creation with managed identity and ACR integration
- Kubernetes deployment, service, and ingress (NGINX) routing
- Practical cost guardrails: deploy → validate → destroy workflow
- Baseline platform engineering documentation (decisions + cost model)

## Future production enhancements

- Private AKS cluster and private endpoints  
- Key Vault CSI driver for secret management  
- Horizontal Pod Autoscaler (HPA)  
- Azure Monitor for containers  
- Network policies and egress control