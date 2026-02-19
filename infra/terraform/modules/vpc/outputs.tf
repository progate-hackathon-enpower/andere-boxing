output "vpc_id" {
  value       = aws_vpc.main.id
  description = "VPC ID"
}

output "vpc_cidr" {
  value       = aws_vpc.main.cidr_block
  description = "VPC CIDR block"
}

output "public_subnet_ids" {
  value       = aws_subnet.public[*].id
  description = "Public subnet IDs"
}

output "private_subnet_eks_ids" {
  value       = aws_subnet.eks[*].id
  description = "Private EKS subnet IDs"
}

output "private_subnet_observability_ids" {
  value       = aws_subnet.observability[*].id
  description = "Private observability subnet IDs"
}

output "private_subnet_lambda_ids" {
  value       = aws_subnet.lambda[*].id
  description = "Private Lambda subnet IDs"
}

output "internet_gateway_id" {
  value       = aws_internet_gateway.main.id
  description = "Internet Gateway ID"
}

output "private_subnet_ids" {
  value = concat(
    aws_subnet.eks[*].id,
    aws_subnet.observability[*].id,
    aws_subnet.lambda[*].id
  )
  description = "All private subnet IDs for NAT Gateway routing"
}

output "all_subnet_ids" {
  value = concat(
    aws_subnet.public[*].id,
    aws_subnet.eks[*].id,
    aws_subnet.observability[*].id,
    aws_subnet.lambda[*].id
  )
  description = "All subnet IDs"
}
