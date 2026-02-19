output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "VPC ID"
}

output "vpc_cidr" {
  value       = module.vpc.vpc_cidr
  description = "VPC CIDR block"
}

output "public_subnet_id" {
  value       = module.vpc.public_subnet_id
  description = "Public subnet ID"
}

output "private_subnet_eks_id" {
  value       = module.vpc.private_subnet_eks_id
  description = "Private EKS subnet ID"
}

output "private_subnet_observability_id" {
  value       = module.vpc.private_subnet_observability_id
  description = "Private observability subnet ID"
}

output "private_subnet_lambda_id" {
  value       = module.vpc.private_subnet_lambda_id
  description = "Private Lambda subnet ID"
}

output "internet_gateway_id" {
  value       = module.vpc.internet_gateway_id
  description = "Internet Gateway ID"
}

output "nat_gateway_id" {
  value       = module.nat_gateway.nat_gateway_id
  description = "NAT Gateway ID"
}

output "nat_gateway_ip" {
  value       = module.nat_gateway.nat_eip
  description = "NAT Gateway Elastic IP"
}

output "public_route_table_id" {
  value       = module.nat_gateway.public_route_table_id
  description = "Public route table ID"
}

output "private_route_table_id" {
  value       = module.nat_gateway.private_route_table_id
  description = "Private route table ID"
}
