# Minikube Kubernetes Cluster Module
# Uses existing Minikube cluster

terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
  }
}

# Provider configuration for Minikube
provider "kubernetes" {
  config_path    = var.kubeconfig_path
  config_context = var.kube_context
}

# Create namespace for the application
resource "kubernetes_namespace" "app" {
  metadata {
    name = var.namespace
    labels = {
      name        = var.namespace
      environment = var.environment
      managed-by  = "terraform"
    }
  }
}

# Storage class for persistent volumes
resource "kubernetes_storage_class" "local" {
  metadata {
    name = "local-storage"
  }
  storage_provisioner = "k8s.io/minikube-hostpath"
  reclaim_policy      = "Delete"
  volume_binding_mode = "Immediate"
}
