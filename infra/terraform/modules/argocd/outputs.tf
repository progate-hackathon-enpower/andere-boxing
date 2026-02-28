output "argocd_namespace" {
  value       = var.argocd_namespace
  description = "ArgoCD namespace"
}

output "argocd_release_name" {
  value       = helm_release.argocd.name
  description = "ArgoCD Helm release name"
}
