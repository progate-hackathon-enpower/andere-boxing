output "argocd_namespace" {
  value       = module.argocd.argocd_namespace
  description = "ArgoCD namespace"
}

output "argocd_release_name" {
  value       = module.argocd.argocd_release_name
  description = "ArgoCD Helm release name"
}
