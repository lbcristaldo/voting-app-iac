# Voting App - Infrastructure as Code

Production-ready infrastructure automation for the Docker Voting App using Terraform and Helm.

 Application Architecture
The voting app consists of 5 microservices:

- **Vote** (Python Flask): Frontend where users vote
- **Redis**: In-memory queue for votes
- **Worker** (.NET): Processes votes from Redis to PostgreSQL
- **DB** (PostgreSQL): Persistent storage for votes
- **Result** (Node.js): Real-time results dashboard

```
┌─────────┐      ┌───────┐      ┌────────┐      ┌──────┐      ┌────────┐
│  Vote   │─────▶│ Redis │─────▶│ Worker │─────▶│  DB  │◀─────│ Result │
│ (Flask) │      │       │      │ (.NET) │      │(Postgres)│   │(Node.js)│
└─────────┘      └───────┘      └────────┘      └──────┘      └────────┘

## Infrastructure Stack
    Terraform: Provisions Kubernetes cluster and resources
    Helm: Deploys and manages application services
    GitHub Actions: CI/CD automation

## Project Structure

voting-app-infrastructure/
├── terraform/              # Infrastructure provisioning
│   ├── environments/
│   │   ├── dev/           # Development environment
│   │   └── prod/          # Production environment
│   └── modules/
│       ├── kubernetes-cluster/
│       ├── networking/
│       └── helm-releases/
├── helm/                   # Application deployment
│   ├── vote/              # Vote service chart
│   ├── result/            # Result service chart
│   ├── worker/            # Worker service chart
│   ├── redis/             # Redis chart
│   └── db/                # PostgreSQL chart
├── .github/workflows/      # CI/CD pipelines
└── docs/                   # Documentation

## Quick Start
 Prerequisites:

    Terraform >= 1.5
    Helm >= 3.0
    kubectl configured
    Cloud provider account (GCP/AWS) or Minikube

## Deploy to Development
cd terraform/environments/dev
terraform init
terraform plan
terraform apply

cd ../../../helm
helm install vote ./vote -f vote/values-dev.yaml
helm install redis ./redis -f redis/values-dev.yaml
helm install worker ./worker -f worker/values-dev.yaml
helm install db ./db -f db/values-dev.yaml
helm install result ./result -f result/values-dev.yaml

## Features
    - Multi-environment support (dev/prod)
    - Terraform modules for reusability
    - Helm charts for each microservice
    - Automated CI/CD with GitHub Actions
    - Monitoring with Prometheus/Grafana
    - Ingress with TLS
    - Auto-scaling policies

### Original Application
Based on: https://github.com/dockersamples/example-voting-app

Author: Luciana Cristaldo - 2025

### Infrastructure modernization and automation project demonstrating:
- Infrastructure as Code with Terraform
- GitOps with Helm
- Kubernetes orchestration
- Multi-service deployment automation
