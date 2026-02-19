output "nat_gateway_id" {
  value       = aws_nat_gateway.main.id
  description = "NAT Gateway ID"
}

output "nat_eip" {
  value       = aws_eip.nat.public_ip
  description = "NAT Gateway Elastic IP"
}

output "public_route_table_id" {
  value       = aws_route_table.public.id
  description = "Public route table ID"
}

output "private_route_table_id" {
  value       = aws_route_table.private.id
  description = "Private route table ID"
}
