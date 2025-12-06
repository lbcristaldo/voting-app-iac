# Vote Helm Chart

Python Flask frontend where users cast their votes.

## Purpose

- User-facing web UI
- Captures votes (Cats vs Dogs)
- Sends votes to Redis queue
- **Entry point** of the application

## Architecture
```
User → Vote (Flask) → Redis
```

## Installation
```bash
helm install vote . -f values-dev.yaml --namespace voting-app-dev

# Check status
kubectl get pods -n voting-app-dev -l app=vote
kubectl get svc -n voting-app-dev vote

# Access locally
kubectl port-forward -n voting-app-dev svc/vote 5000:5000
# Open: http://localhost:5000
```

## Configuration

- **Redis connection**: Expects Redis service at `redis:6379`
- **Vote options**: Configurable via `voteOptions` (default: Cats vs Dogs)
- **Replicas**: 1 in dev, 2+ in prod for HA

## Image Tagging Strategy

**Current:** Using `before` tag (stable snapshot) and SHA256 digest for immutability

**Production recommendations:**
- Use semantic versioning for your own images
- Never use `latest` in production
- Implement image scanning in CI/CD

Example with SHA:
```yaml
image:
  repository: myregistry/vote
  tag: "sha256:abc123..."
  # Or semantic version:
  tag: "v1.2.3"

## Testing
```bash
# View logs
kubectl logs -n voting-app-dev -l app=vote -f

# Test vote submission
curl -X POST http://localhost:5000/ -d "vote=a"

# Check Redis received it
kubectl exec -it -n voting-app-dev deployment/redis -- redis-cli LRANGE votes 0 -1
```

## Troubleshooting

### Cannot connect to Redis
```bash
# Check Redis is running
kubectl get pods -n voting-app-dev -l app=redis

# Check service
kubectl get svc -n voting-app-dev redis

# Test connectivity
kubectl exec -it -n voting-app-dev deployment/vote -- ping redis
```

### Pod CrashLoopBackOff
```bash
kubectl logs -n voting-app-dev -l app=vote --previous
```

Common issue: Redis not available yet (deploy Redis first)

## Access Methods

**Dev (port-forward):**
```bash
kubectl port-forward -n voting-app-dev svc/vote 5000:5000
```

**Prod (Ingress):**
Will be configured with Ingress controller + TLS


