variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "ap-northeast-1"
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "project_name" {
  type        = string
  description = "Project name"
}

variable "argocd_chart_version" {
  type        = string
  description = "ArgoCD Helm chart version"
  default     = "7.8.13"
}
