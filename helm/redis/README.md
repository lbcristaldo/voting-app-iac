# Redis Helm Chart

In-memory data store and message queue for the voting app.

## Purpose

- Receives votes from the Vote service
- Queues votes for processing by Worker
- No persistence needed (votes are temporary)

## Installation
```bash
# Development
helm install redis . -f values-dev.yaml --namespace voting-app-dev

# Check status
kubectl get pods -n voting-app-dev -l app=redis
kubectl logs -n voting-app-dev -l app=redis

# Test connection
kubectl run -it --rm redis-test --image=redis:7.0-alpine --restart=Never -- redis-cli -h redis ping
```

## Configuration

Key values in `values-dev.yaml`:

- **replicas**: 1 (single instance for dev)
- **resources**: Minimal (50m CPU, 64Mi RAM)
- **persistence**: Disabled (in-memory only)

## Connecting from other services
```yaml
# Vote service connects via:
- name: REDIS_HOST
  value: "redis"  # Service name
- name: REDIS_PORT
  value: "6379"
```

## Troubleshooting
```bash
# Check if running
kubectl get pods -n voting-app-dev -l app=redis

# View logs
kubectl logs -n voting-app-dev -l app=redis -f

# Test connectivity
kubectl exec -it -n voting-app-dev deployment/redis -- redis-cli ping
# Should return: PONG
```
