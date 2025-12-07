# KEDA Autoscaling Helm Chart

Event-driven autoscaling for the Worker service based on Redis queue length.

## Purpose

Automatically scales the Worker deployment up or down based on the number of pending votes in the Redis queue.

## Architecture
```
Redis Queue → KEDA (monitors) → Worker Deployment (0-10 replicas)
```

## How it works

1. **KEDA polls Redis** every 30 seconds
2. **Checks `votes` list length** in Redis
3. **Calculates needed replicas:**
   - Formula: `replicas = ceil(queueLength / listLength)`
   - Example: 15 votes ÷ 5 per worker = 3 workers
4. **Adjusts Worker deployment** automatically
5. **Scales to zero** when queue is empty (if minReplicaCount = 0)

## Prerequisites

- KEDA installed in cluster:
```bash
  helm repo add kedacore https://kedacore.github.io/charts
  helm install keda kedacore/keda --namespace keda --create-namespace
```
- Worker deployment running
- Redis service accessible

## Installation
```bash
# Install with dev values
helm install keda-worker-autoscaling . \
  -f values-dev.yaml \
  --namespace voting-app-dev

# Verify ScaledObject created
kubectl get scaledobject -n voting-app-dev

# Check KEDA operator logs
kubectl logs -n keda -l app=keda-operator -f
```

## Configuration

Key values:

### Scaling Behavior
```yaml
scaling:
  minReplicaCount: 1    # Minimum workers (0 = scale to zero)
  maxReplicaCount: 5    # Maximum workers
  cooldownPeriod: 60    # Seconds before scaling down
  pollingInterval: 30   # How often to check queue
```

### Redis Trigger
```yaml
redis:
  host: "redis.voting-app-dev.svc.cluster.local"
  listName: "votes"     # Queue name
  listLength: "3"       # Messages per worker
```

**Example:** If there are 12 votes in queue and `listLength: 3`, KEDA creates 4 workers (12 ÷ 3 = 4).

## Testing

### 1. Monitor current state
```bash
# Watch Worker replicas change
kubectl get pods -n voting-app-dev -l app=worker -w

# Check ScaledObject status
kubectl get scaledobject -n voting-app-dev worker-scaledobject -o yaml
```

### 2. Generate load
```bash
# Vote multiple times quickly
for i in {1..20}; do
  curl -X POST http://localhost:5000 -d "vote=a"
done
```

### 3. Observe scaling
```bash
# Check queue length
kubectl exec -n voting-app-dev deployment/redis -- redis-cli LLEN votes

# Watch workers scale up
kubectl get hpa -n voting-app-dev

# View KEDA decision logs
kubectl logs -n keda -l app=keda-operator --tail=50
```

### 4. Verify scale down

Wait 1-2 minutes after queue is empty. Workers should scale down to `minReplicaCount`.

## Monitoring

### Check ScaledObject
```bash
kubectl describe scaledobject -n voting-app-dev worker-scaledobject
```

Look for:
- `Status: Ready`
- `Active: True` (when scaling is happening)
- Events showing scaling decisions

### View HPA created by KEDA
```bash
kubectl get hpa -n voting-app-dev

# Detailed view
kubectl describe hpa -n voting-app-dev keda-hpa-worker-scaledobject
```

### KEDA Operator Logs
```bash
kubectl logs -n keda deploy/keda-operator -f
```

Shows when KEDA detects queue changes and makes scaling decisions.

## Troubleshooting

### ScaledObject not triggering

**Check Redis connection:**
```bash
kubectl run -it --rm redis-test --image=redis:7.0-alpine --restart=Never -- \
  redis-cli -h redis.voting-app-dev.svc.cluster.local LLEN votes
```

**Check ScaledObject status:**
```bash
kubectl get scaledobject -n voting-app-dev worker-scaledobject -o yaml | grep -A 10 status
```

### Workers not scaling up

**Verify queue has messages:**
```bash
kubectl exec -n voting-app-dev deployment/redis -- redis-cli LLEN votes
```

**Check KEDA operator logs:**
```bash
kubectl logs -n keda -l app=keda-operator --tail=100
```

**Verify HPA exists:**
```bash
kubectl get hpa -n voting-app-dev
```

### Workers stuck at max replicas

Check if queue is actually draining:
```bash
watch kubectl exec -n voting-app-dev deployment/redis -- redis-cli LLEN votes
```

If queue length stays high, workers might not be processing properly. Check Worker logs:
```bash
kubectl logs -n voting-app-dev -l app=worker -f
```

## Advanced Configuration

### Scale to Zero

Enable scale-to-zero for maximum resource efficiency:
```yaml
scaling:
  minReplicaCount: 0
```

**Trade-off:** First vote after idle period has 10-15s latency while pod starts.

### Aggressive Scaling

For high-traffic scenarios:
```yaml
redis:
  listLength: "10"  # Each worker handles 10 messages

scaling:
  maxReplicaCount: 20
  pollingInterval: 10  # Check every 10 seconds
```

### Custom Scaling Behavior

Control how fast to scale up/down:
```yaml
advanced:
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 0  # Scale up immediately
      policies:
      - type: Pods
        value: 5  # Add 5 pods at once if needed
        periodSeconds: 15
```

## Uninstall
```bash
# Remove ScaledObject (Worker returns to original replica count)
helm uninstall keda-worker-autoscaling --namespace voting-app-dev

# Workers return to replica count specified in worker chart
kubectl get deployment -n voting-app-dev worker
```

## Production Recommendations

- [ ] Set `minReplicaCount: 2` for high availability
- [ ] Use Redis password authentication (add Secret reference)
- [ ] Set `maxReplicaCount` based on cluster capacity
- [ ] Monitor KEDA metrics with Prometheus
- [ ] Set up alerts for scaling failures
- [ ] Test scale-to-zero latency impact
- [ ] Configure PodDisruptionBudget for Workers

## References

- [KEDA Documentation](https://keda.sh/docs/)
- [Redis Scaler Spec](https://keda.sh/docs/scalers/redis-lists/)
- [ScaledObject Specification](https://keda.sh/docs/concepts/scaling-deployments/)
