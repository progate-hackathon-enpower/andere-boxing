variable "project_name" {
  type        = string
  description = "Project name"
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "argocd_chart_version" {
  type        = string
  description = "ArgoCD Helm chart version"
  default     = "7.8.13"
}

variable "argocd_namespace" {
  type        = string
  description = "Kubernetes namespace for ArgoCD"
  default     = "argocd"
}


variable "tags" {
  type        = map(string)
  description = "Common tags"
  default     = {}
}
