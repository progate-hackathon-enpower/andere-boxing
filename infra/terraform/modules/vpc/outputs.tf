output "vpc_id" {
  value       = aws_vpc.main.id
  description = "VPC ID"
}

output "vpc_cidr" {
  value       = aws_vpc.main.cidr_block
  description = "VPC CIDR block"
}

output "public_subnet_id" {
  value       = aws_subnet.public.id
  description = "Public subnet ID"
}

output "private_subnet_eks_id" {
  value       = aws_subnet.eks.id
  description = "Private EKS subnet ID"
}

output "private_subnet_observability_id" {
  value       = aws_subnet.observability.id
  description = "Private observability subnet ID"
}

output "private_subnet_lambda_id" {
  value       = aws_subnet.lambda.id
  description = "Private Lambda subnet ID"
}

output "internet_gateway_id" {
  value       = aws_internet_gateway.main.id
  description = "Internet Gateway ID"
}

output "private_subnet_ids" {
  value = [
    aws_subnet.eks.id,
    aws_subnet.observability.id,
    aws_subnet.lambda.id
  ]
  description = "Private subnet IDs for NAT Gateway routing"
}

output "all_subnet_ids" {
  value = [
    aws_subnet.public.id,
    aws_subnet.eks.id,
    aws_subnet.observability.id,
    aws_subnet.lambda.id
  ]
  description = "All subnet IDs"
}
