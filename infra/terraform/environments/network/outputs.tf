output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "VPC ID"
}

output "vpc_cidr" {
  value       = module.vpc.vpc_cidr
  description = "VPC CIDR block"
}

output "public_subnet_ids" {
  value       = module.vpc.public_subnet_ids
  description = "Public subnet IDs"
}

output "private_subnet_eks_ids" {
  value       = module.vpc.private_subnet_eks_ids
  description = "Private EKS subnet IDs"
}

output "private_subnet_observability_ids" {
  value       = module.vpc.private_subnet_observability_ids
  description = "Private observability subnet IDs"
}

output "private_subnet_lambda_ids" {
  value       = module.vpc.private_subnet_lambda_ids
  description = "Private Lambda subnet IDs"
}

output "internet_gateway_id" {
  value       = module.vpc.internet_gateway_id
  description = "Internet Gateway ID"
}

output "nat_gateway_ids" {
  value       = module.nat_gateway.nat_gateway_ids
  description = "NAT Gateway IDs"
}

output "nat_gateway_ips" {
  value       = module.nat_gateway.nat_eips
  description = "NAT Gateway Elastic IPs"
}

output "public_route_table_ids" {
  value       = module.nat_gateway.public_route_table_ids
  description = "Public route table IDs"
}

output "private_route_table_ids" {
  value       = module.nat_gateway.private_route_table_ids
  description = "Private route table IDs"
}
