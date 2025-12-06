# Worker Helm Chart

.NET background service that processes votes from Redis to PostgreSQL.

## Purpose

Consumes votes from Redis queue and persists them to PostgreSQL database.

## Architecture
```
Redis → Worker (.NET) → PostgreSQL
(queue)  (processor)    (storage)
```

## Installation
```bash
helm install worker . -f values-dev.yaml --namespace voting-app-dev

# Check status
kubectl get pods -n voting-app-dev -l app=worker
kubectl logs -n voting-app-dev -l app=worker -f
```

## Configuration

Connects to:
- **Redis**: `redis:6379` (source queue)
- **PostgreSQL**: `db:5432` (destination storage)

Credentials pulled from `db` secret (created by db chart).

## How it works

1. Connects to Redis
2. Polls for new votes
3. Writes each vote to PostgreSQL `votes` table
4. Removes processed vote from Redis

**No HTTP endpoints** - pure background worker.

## Monitoring
```bash
# View processing logs
kubectl logs -n voting-app-dev -l app=worker -f

# Check if stuck (restart count)
kubectl get pods -n voting-app-dev -l app=worker

# Force restart if needed
kubectl rollout restart deployment/worker -n voting-app-dev
```

## Troubleshooting

**Worker CrashLoopBackOff:**

Usually means Redis or PostgreSQL not available.
```bash
# Check dependencies
kubectl get pods -n voting-app-dev -l app=redis
kubectl get pods -n voting-app-dev -l app=db

# View error logs
kubectl logs -n voting-app-dev -l app=worker --previous
```

**Votes not processing:**
```bash
# Check Redis has votes
kubectl exec -it -n voting-app-dev deployment/redis -- redis-cli LLEN votes

# Check PostgreSQL connection
kubectl exec -it -n voting-app-dev deployment/db -- \
  psql -U postgres -c "SELECT COUNT(*) FROM votes;"
```

## Scaling with KEDA (future)

Worker is perfect for event-driven autoscaling:
- Scale based on Redis queue length
- More votes = more workers
- Zero votes = scale to zero
