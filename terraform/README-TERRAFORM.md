# Terraform Infrastructure

Provisions Kubernetes cluster and base resources for the voting app.

## Structure
```
terraform/
├── environments/
│   ├── dev/          # Development (Minikube)
│   └── prod/         # Production (GKE) - Coming soon
├── modules/
│   └── kubernetes-cluster/
│       └── minikube/ # Minikube cluster module
└── scripts/
    └── validate-minikube.sh  # Pre-flight checks
```

## Prerequisites

- Minikube installed and running
- kubectl configured
- Terraform >= 1.5
- Helm >= 3.0

## Quick Start

### 1. Validate environment
```bash
cd scripts
./validate-minikube.sh
```

### 2. Initialize Terraform
```bash
cd ../environments/dev
terraform init
```

### 3. Review plan
```bash
terraform plan
```

### 4. Apply infrastructure
```bash
terraform apply
```

### 5. Verify
```bash
kubectl get namespaces | grep voting-app
kubectl get storageclass
```

## What gets created?

- Kubernetes namespace: `voting-app-dev`
- Storage class: `local-storage`
- Labels and metadata for resource management

## Next Steps

After Terraform completes:

1. Deploy application with Helm:
```bash
   cd ../../helm
   ./deploy-dev.sh
```

2. Access services:
```bash
   kubectl port-forward -n voting-app-dev svc/vote 5000:5000
   kubectl port-forward -n voting-app-dev svc/result 5001:5001
```

## Cleanup
```bash
terraform destroy
```

## Troubleshooting

### "Error: Kubernetes cluster unreachable"
```bash
kubectl cluster-info
minikube status
```

### "Context minikube not found"
```bash
kubectl config get-contexts
# Use the correct context in terraform.tfvars
```

### Starting fresh
```bash
minikube delete
minikube start --memory=4096 --cpus=2
```
