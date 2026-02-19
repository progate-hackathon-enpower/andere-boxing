output "nat_gateway_ids" {
  value       = aws_nat_gateway.main[*].id
  description = "NAT Gateway IDs"
}

output "nat_eips" {
  value       = aws_eip.nat[*].public_ip
  description = "NAT Gateway Elastic IPs"
}

output "public_route_table_ids" {
  value       = aws_route_table.public[*].id
  description = "Public route table IDs"
}

output "private_route_table_ids" {
  value       = aws_route_table.private[*].id
  description = "Private route table IDs"
}
