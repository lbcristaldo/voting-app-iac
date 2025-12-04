output "namespace" {
  description = "Created namespace name"
  value       = kubernetes_namespace.app.metadata[0].name
}

output "storage_class" {
  description = "Storage class name"
  value       = kubernetes_storage_class.local.metadata[0].name
}

output "cluster_endpoint" {
  description = "Kubernetes cluster endpoint"
  value       = "minikube"
}
