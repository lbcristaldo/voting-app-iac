Architecture Overview

 Application Flow
1. User votes via Vote frontend (Python Flask)
2. Vote stored in Redis queue
3. Worker (.NET) consumes from Redis, writes to PostgreSQL
4. Result dashboard (Node.js) displays real-time results from DB

 Service Communication
- Vote → Redis (direct)
- Worker → Redis (consumer)
- Worker → PostgreSQL (writer)
- Result → PostgreSQL (reader)

 Infrastructure Components
Terraform Provisions:
- Kubernetes cluster (GKE/Minikube)
- Networking (VPC, subnets)
- Storage classes for persistent volumes
- IAM roles and service accounts

Helm Manages:
- Application deployments
- Services and ingress
- ConfigMaps and secrets
- Resource limits and scaling

 Environments
Dev
- Single node cluster
- Minimal resources
- No ingress (port-forward)

Prod
- Multi-node cluster
- Resource limits enforced
- Ingress with TLS
- Monitoring enabled
