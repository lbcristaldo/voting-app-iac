#!/bin/bash

set -e

echo "Validating Minikube setup..."

# Check if minikube is installed
if ! command -v minikube &> /dev/null; then
    echo "❌ Minikube not installed"
    echo "Install: brew install minikube"
    exit 1
fi

# Check if minikube is running
if ! minikube status &> /dev/null; then
    echo "❌ Minikube is not running"
    echo "Start with: minikube start"
    exit 1
fi

# Check kubectl
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl not installed"
    exit 1
fi

# Check kubectl can connect
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ kubectl cannot connect to cluster"
    exit 1
fi

# Check terraform
if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform not installed"
    echo "Install: brew install terraform"
    exit 1
fi

# Check helm
if ! command -v helm &> /dev/null; then
    echo "❌ Helm not installed"
    echo "Install: brew install helm"
    exit 1
fi

echo "✅ All prerequisites satisfied!"
echo ""
echo "Cluster info:"
kubectl cluster-info
echo ""
echo "Ready to run: terraform init && terraform apply"


chmod +x validate-minikube.sh
