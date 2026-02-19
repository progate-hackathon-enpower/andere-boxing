output "eks_cluster_security_group_id" {
  description = "EKS cluster security group ID"
  value       = aws_security_group.eks_cluster.id
}

output "eks_private_node_security_group_id" {
  description = "EKS private node security group ID"
  value       = aws_security_group.eks_private_node.id
}

output "eks_public_node_security_group_id" {
  description = "EKS public node security group ID"
  value       = aws_security_group.eks_public_node.id
}
