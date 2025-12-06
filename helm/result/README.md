# Result Helm Chart

Node.js real-time dashboard displaying voting results.

## Purpose

Reads votes from PostgreSQL and displays them in real-time web UI.

## Architecture
```
PostgreSQL → Result (Node.js) → User Browser
(storage)    (dashboard)         (websocket)
```

## Installation
```bash
helm install result . -f values-dev.yaml --namespace voting-app-dev

# Check status
kubectl get pods -n voting-app-dev -l app=result

# Access locally
kubectl port-forward -n voting-app-dev svc/result 5001:5001
# Open: http://localhost:5001
```

## Configuration

Connects to PostgreSQL at `db:5432` (read-only).
Uses websockets for real-time updates.

## Testing
```bash
# View logs
kubectl logs -n voting-app-dev -l app=result -f

# Test database connection
kubectl exec -it -n voting-app-dev deployment/result -- \
  wget -qO- http://localhost:80
```

## Troubleshooting

**No votes displaying:**
- Check PostgreSQL has data
- Check Worker is processing votes
- Verify database credentials

**Connection refused:**
```bash
kubectl get pods -n voting-app-dev -l app=db
kubectl logs -n voting-app-dev -l app=result
```
