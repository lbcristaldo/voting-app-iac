output "namespace" {
  description = "Application namespace"
  value       = module.cluster.namespace
}

output "cluster_info" {
  description = "Cluster information"
  value = {
    endpoint      = module.cluster.cluster_endpoint
    storage_class = module.cluster.storage_class
  }
}

output "deployment_instructions" {
  description = "Next steps to deploy the application"
  value = <<-EOT
    
    ✅ Infrastructure ready!
    
    Next steps:
    1. Deploy with Helm:
       cd ../../../helm
       ./deploy-dev.sh
    
    2. Access services:
       kubectl port-forward -n ${module.cluster.namespace} svc/vote 5000:5000
       kubectl port-forward -n ${module.cluster.namespace} svc/result 5001:5001
    
    3. Check status:
       kubectl get all -n ${module.cluster.namespace}
  EOT
}
