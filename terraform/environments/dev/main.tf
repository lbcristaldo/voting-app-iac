# Development Environment Configuration
# Deploys voting app infrastructure to Minikube

terraform {
  required_version = ">= 1.5"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
  }

  # Local backend for dev
  backend "local" {
    path = "terraform.tfstate"
  }
}

# Kubernetes cluster module
module "cluster" {
  source = "../../modules/kubernetes-cluster/minikube"

  namespace   = var.namespace
  environment = var.environment
}

# Helm provider using same kubeconfig
provider "helm" {
  kubernetes {
    config_path    = var.kubeconfig_path
    config_context = var.kube_context
  }
}
