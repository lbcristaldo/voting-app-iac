# Descheduler Configuration

## Overview

Descheduler is a Kubernetes component that optimizes pod placement by periodically evicting pods that violate scheduling policies or are inefficiently distributed across nodes.

## Purpose

The Kubernetes scheduler only acts when pods are **created**. Once running, pods never move even if:
- Node resources become imbalanced
- Scheduling constraints change
- Better placement options become available

Descheduler solves this by continuously evaluating running pods and evicting those that should be rescheduled.

---

## Architecture

```mermaid
graph LR
    CronJob[Descheduler CronJob] -->|Every 5 min| Evaluate[Evaluate Pods]
    Evaluate -->|Check Policies| Decision{Violates Policy?}
    Decision -->|Yes| Evict[Evict Pod]
    Decision -->|No| Skip[Skip]
    Evict -->|Pod Terminated| Scheduler[Kubernetes Scheduler]
    Scheduler -->|Creates New Pod| Optimized[Better Placement]
    
    style CronJob fill:#326CE5,color:#fff
    style Evict fill:#f44336,color:#fff
    style Optimized fill:#4CAF50,color:#fff
```

---

## Installation

```bash
helm repo add descheduler https://kubernetes-sigs.github.io/descheduler/
helm repo update

helm install descheduler descheduler/descheduler \
  --namespace kube-system \
  --set schedule="*/5 * * * *" \
  --set deschedulerPolicy.strategies.RemoveDuplicates.enabled=true \
  --set deschedulerPolicy.strategies.LowNodeUtilization.enabled=true
```

---

## Enabled Strategies

### 1. RemoveDuplicates

**Purpose:** Ensure replicas of the same deployment are distributed across different nodes.

**Example:**
```
Before:
Node 1: [vote-1, vote-2, worker-1]
Node 2: [result-1]

After:
Node 1: [vote-1, worker-1]
Node 2: [result-1, vote-2]
```

**Configuration:**
```yaml
RemoveDuplicates:
  enabled: true
```

### 2. LowNodeUtilization

**Purpose:** Balance resource usage across nodes by moving pods from overutilized to underutilized nodes.

**Thresholds:**
- **Low threshold:** 20% CPU/Memory
  - If a node is below this, it's considered underutilized
- **Target threshold:** 50% CPU/Memory
  - Descheduler tries to bring all nodes to this level

**Example:**
```
Before:
Node 1: 80% CPU (overutilized)
Node 2: 15% CPU (underutilized)

After:
Node 1: 50% CPU
Node 2: 45% CPU
```

**Configuration:**
```yaml
LowNodeUtilization:
  enabled: true
  params:
    nodeResourceUtilizationThresholds:
      thresholds:
        cpu: 20
        memory: 20
      targetThresholds:
        cpu: 50
        memory: 50
```

---

## Verification

### Check CronJob

```bash
kubectl get cronjob -n kube-system descheduler
```

Expected output:
```
NAME          SCHEDULE      SUSPEND   ACTIVE   LAST SCHEDULE   AGE
descheduler   */5 * * * *   False     0        2m             10m
```

### View Execution History

```bash
kubectl get jobs -n kube-system -l app.kubernetes.io/name=descheduler
```

Shows completed descheduling runs.

### View Logs

```bash
kubectl logs -n kube-system -l app.kubernetes.io/name=descheduler --tail=100
```

Look for:
- `Evicted pod` - Pods that were moved
- `Skipping descheduling cycle` - Reason why descheduling was skipped

---

## Behavior in Different Environments

### Minikube (Single Node)

```
Skipping descheduling cycle >= 2 nodes found
```

**Why?** Descheduler requires multiple nodes to optimize placement. With only 1 node, all pods must stay there.

**Impact:** Descheduler runs but performs no evictions. This is **expected and correct behavior**.

### Multi-Node Cluster (GKE/EKS/AKS)

Descheduler actively:
- Redistributes replicas across nodes
- Balances resource utilization
- Enforces anti-affinity rules
- Respects PodDisruptionBudgets

**Example log from multi-node cluster:**
```
Processing node: gke-node-1
Node gke-node-1 is overutilized
Evicting pod vote-abc123 from node gke-node-1
Evicted pod vote-abc123
```

---

## Configuration Details

### Schedule

```yaml
schedule: "*/5 * * * *"
```

Runs every 5 minutes. Adjust based on cluster dynamics:
- **High churn:** `*/2 * * * *` (every 2 minutes)
- **Stable workloads:** `*/10 * * * *` (every 10 minutes)

### DryRun Mode

Test descheduler decisions without actually evicting pods:

```bash
helm upgrade descheduler descheduler/descheduler \
  --namespace kube-system \
  --set dryRun=true
```

Logs will show `Would evict pod X` instead of `Evicted pod X`.

---

## Advanced Strategies (Not Enabled)

### RemovePodsViolatingNodeAffinity

Evicts pods that no longer match their node affinity rules.

**Use case:** Node labels changed after pod was scheduled.

### RemovePodsViolatingInterPodAntiAffinity

Ensures pods that should not colocate are separated.

**Use case:** Database replicas must be on different nodes for HA.

### RemovePodsViolatingTopologySpreadConstraint

Enforces even distribution across topology domains (zones, regions).

**Use case:** One replica per availability zone.

### RemovePodsHavingTooManyRestarts

Evicts crashlooping pods to trigger rescheduling to potentially healthier nodes.

**Use case:** Node with bad disk causing pod failures.

---

## Monitoring

### Prometheus Metrics

Descheduler exposes metrics on port 10258:

```yaml
descheduler_pods_evicted_total
descheduler_build_info
```

Scrape with:
```yaml
- job_name: descheduler
  static_configs:
  - targets: ['descheduler.kube-system:10258']
```

### Grafana Dashboard

Monitor:
- Pods evicted over time
- Eviction reasons
- Strategy effectiveness

---

## Safety Features

### PodDisruptionBudgets

Descheduler **respects** PodDisruptionBudgets. It will NOT evict pods if it would violate a PDB.

**Example:**
```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: worker-pdb
spec:
  minAvailable: 1
  selector:
    matchLabels:
      app: worker
```

If only 1 worker is running, Descheduler won't evict it.

### Critical Pods

Pods with `system-cluster-critical` or `system-node-critical` priority classes are **never evicted**.

### Namespace Exclusions

Certain namespaces are excluded by default:
- `kube-system`
- `kube-public`
- `kube-node-lease`

---

## Troubleshooting

### Descheduler not evicting pods

**Check node count:**
```bash
kubectl get nodes
```
Need ≥2 nodes for most strategies.

**Check pod priority:**
High-priority pods are protected from eviction.

**Check PodDisruptionBudgets:**
```bash
kubectl get pdb --all-namespaces
```

### Too many evictions

**Increase thresholds:**
```yaml
thresholds:
  cpu: 30  # Increase from 20
  memory: 30
```

**Reduce frequency:**
```yaml
schedule: "*/15 * * * *"  # Every 15 minutes instead of 5
```

### Pods being evicted repeatedly

**Add anti-affinity rules** to prevent pods from returning to the same overutilized node:

```yaml
affinity:
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 100
      podAffinityTerm:
        labelSelector:
          matchLabels:
            app: vote
        topologyKey: kubernetes.io/hostname
```

---

## Uninstall

```bash
helm uninstall descheduler --namespace kube-system
```

---

## Production Recommendations

- [ ] Enable `RemovePodsViolatingInterPodAntiAffinity` for HA workloads
- [ ] Set up Prometheus monitoring of eviction metrics
- [ ] Configure PodDisruptionBudgets for critical services
- [ ] Start with `dryRun: true` to validate behavior
- [ ] Tune thresholds based on actual cluster utilization patterns
- [ ] Consider `RemovePodsViolatingTopologySpreadConstraint` for multi-AZ clusters

---

## References

- [Descheduler Documentation](https://github.com/kubernetes-sigs/descheduler)
- [Kubernetes Eviction API](https://kubernetes.io/docs/concepts/scheduling-eviction/api-eviction/)
- [Pod Disruption Budgets](https://kubernetes.io/docs/tasks/run-application/configure-pdb/)
