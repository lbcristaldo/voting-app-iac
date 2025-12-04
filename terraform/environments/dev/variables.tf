variable "kubeconfig_path" {
  description = "Path to kubeconfig file"
  type        = string
  default     = "~/.kube/config"
}

variable "kube_context" {
  description = "Kubernetes context to use"
  type        = string
  default     = "minikube"
}

variable "namespace" {
  description = "Kubernetes namespace for the application"
  type        = string
  default     = "voting-app-dev"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "vote_replicas" {
  description = "Number of vote service replicas"
  type        = number
  default     = 1
}

variable "result_replicas" {
  description = "Number of result service replicas"
  type        = number
  default     = 1
}

variable "worker_replicas" {
  description = "Number of worker service replicas"
  type        = number
  default     = 1
}
