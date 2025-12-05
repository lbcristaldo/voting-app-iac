# PostgreSQL Helm Chart

Persistent database for storing votes in the voting app.

## Purpose

- Stores processed votes from Worker service
- Provides data to Result dashboard
- **Persistent storage** - data survives pod restarts

## Architecture
```
Worker → PostgreSQL ← Result
  (write)         (read)
```

## Installation
```bash
# Development
helm install db . -f values-dev.yaml --namespace voting-app-dev

# Check status
kubectl get pods -n voting-app-dev -l app=db
kubectl get pvc -n voting-app-dev

# View logs
kubectl logs -n voting-app-dev -l app=db -f
```

## Database Schema

Automatically created on first run:
```sql
CREATE TABLE votes (
  id VARCHAR(255) NOT NULL UNIQUE,
  vote VARCHAR(255) NOT NULL
);
```

## Configuration

Key values in `values-dev.yaml`:

- **persistence**: Enabled with 500Mi storage
- **storageClass**: `local-storage` (created by Terraform)
- **credentials**: postgres/postgres (dev only!)
- **resources**: 100m CPU, 128Mi RAM

## Persistent Storage

Uses a **PersistentVolumeClaim** (PVC):
```bash
# Check PVC
kubectl get pvc -n voting-app-dev

# Check data persistence
kubectl exec -it -n voting-app-dev deployment/db -- psql -U postgres -c "SELECT * FROM votes;"
```

**Data survives pod restarts!**

## Connecting from other services
```yaml
# Worker and Result connect via:
- name: POSTGRES_HOST
  value: "db"  # Service name
- name: POSTGRES_PORT
  value: "5432"
- name: POSTGRES_USER
  valueFrom:
    secretKeyRef:
      name: db
      key: POSTGRES_USER
- name: POSTGRES_PASSWORD
  valueFrom:
    secretKeyRef:
      name: db
      key: POSTGRES_PASSWORD
```

## Troubleshooting

### Pod not starting
```bash
# Check events
kubectl describe pod -n voting-app-dev -l app=db

# Common issue: PVC not bound
kubectl get pvc -n voting-app-dev
# Should show STATUS: Bound
```

### Database connection issues
```bash
# Test from inside pod
kubectl exec -it -n voting-app-dev deployment/db -- psql -U postgres

# Test from another pod
kubectl run -it --rm psql-test --image=postgres:15-alpine --restart=Never -- \
  psql -h db -U postgres -d postgres
```

### View database content
```bash
kubectl exec -it -n voting-app-dev deployment/db -- \
  psql -U postgres -c "SELECT * FROM votes;"
```

### Reset database
```bash
# Delete pod and PVC (data will be lost!)
helm uninstall db --namespace voting-app-dev
kubectl delete pvc -n voting-app-dev -l app=db

# Reinstall
helm install db . -f values-dev.yaml --namespace voting-app-dev
```

## Production Considerations

For production, you should:

- [ ] Use strong passwords (stored in external secret manager)
- [ ] Enable backups (pg_dump cronjobs)
- [ ] Use cloud provider managed PostgreSQL (RDS, Cloud SQL)
- [ ] Configure replication for high availability
- [ ] Set up monitoring (pg_stat_statements)
- [ ] Tune performance (shared_buffers, work_mem)
