## Autoscaling Validation (HPA)

### Outcome
- HPA successfully scaled the `hello` Deployment based on CPU utilization.
- Target CPU: **50%** (percentage of requested CPU)
- Observed CPU: **144%**
- Replicas: **1 → 3**

### HPA Summary

| HPA | Target | Min | Max | Replicas | Notes |
|-----|--------|-----|-----|----------|------|
| hello-hpa | CPU 144% / 50% | 1 | 5 | 3 | Scale-out triggered due to CPU above target |

### HPA Conditions (Key Signals)
- **ScalingActive:** True — valid CPU metric found
- **AbleToScale:** True — controller ready to scale
- **ScalingLimited:** False — desired replicas within configured range

### Recent Rescale Event
- **SuccessfulRescale:** New size **3** because CPU utilization was above target.

### Running Pods (Post Scale-Out)

| Pod | Ready | Status | Age |
|-----|-------|--------|-----|
| hello-754686d7f4-2shws | 1/1 | Running | 115s |
| hello-754686d7f4-6rrgn | 1/1 | Running | 27s |
| hello-754686d7f4-vnrtf | 1/1 | Running | 27s |

### Notes on Warnings
During scale-out, HPA may briefly report metric fetch warnings (e.g., “pods might be unready”) while new pods are starting. This is expected transient behavior; scaling proceeded successfully once pods became ready.

<details>
<summary>Raw kubectl output</summary>

```text
NAME REFERENCE TARGETS MINPODS MAXPODS REPLICAS AGE hello-hpa Deployment/hello cpu: 144%/50% 1 5 3 102s Name: hello-hpa Namespace: default Labels: <none> Annotations: <none> CreationTimestamp: Sun, 22 Feb 2026 05:23:17 +0000 Reference: Deployment/hello Metrics: ( current / target ) resource cpu on pods (as a percentage of request): 144% (72m) / 50% Min replicas: 1 Max replicas: 5 Deployment pods: 3 current / 3 desired Conditions: Type Status Reason Message ---- ------ ------ ------- AbleToScale True ReadyForNewScale recommended size matches current size ScalingActive True ValidMetricFound the HPA was able to successfully calculate a replica count from cpu resource utilization (percentage of request) ScalingLimited False DesiredWithinRange the desired count is within the acceptable range Events: Type Reason Age From Message ---- ------ ---- ---- ------- Warning FailedGetResourceMetric 42s (x4 over 87s) horizontal-pod-autoscaler failed to get cpu utilization: did not receive metrics for targeted pods (pods might be unready) Warning FailedComputeMetricsReplicas 42s (x4 over 87s) horizontal-pod-autoscaler invalid metrics (1 invalid out of 1), first error is: failed to get cpu resource metric value: failed to get cpu utilization: did not receive metrics for targeted pods (pods might be unready) Normal SuccessfulRescale 27s horizontal-pod-autoscaler New size: 3; reason: cpu resource utilization (percentage of request) above target NAME READY STATUS RESTARTS AGE IP NODE NOMINATED NODE READINESS GATES hello-754686d7f4-2shws 1/1 Running 0 115s 10.244.0.54 aks-nodepool1-41997106-vmss000000 <none> <none> hello-754686d7f4-6rrgn 1/1 Running 0 27s 10.244.0.245 aks-nodepool1-41997106-vmss000000 <none> <none> hello-754686d7f4-vnrtf 1/1 Running 0 27s 10.244.0.192 aks-nodepool1-41997106-vmss000000 <none> <none>
```
</details>