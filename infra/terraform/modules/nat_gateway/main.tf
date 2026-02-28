# Elastic IP for NAT Gateways (Multi-AZ)
resource "aws_eip" "nat" {
  count  = length(var.availability_zones)
  domain = "vpc"

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-nat-eip-${count.index + 1}"
    }
  )

  depends_on = []
}

# NAT Gateways (Multi-AZ)
resource "aws_nat_gateway" "main" {
  count         = length(var.availability_zones)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = var.public_subnet_ids[count.index]

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-nat-gateway-${count.index + 1}"
    }
  )

  depends_on = []
}

# Public Route Tables (per AZ)
resource "aws_route_table" "public" {
  count  = length(var.availability_zones)
  vpc_id = data.aws_vpc.main.id

  route {
    cidr_block      = "0.0.0.0/0"
    gateway_id      = var.internet_gateway_id
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-public-rt-${count.index + 1}"
    }
  )
}

# Associate public subnets with public route tables
resource "aws_route_table_association" "public" {
  count          = length(var.availability_zones)
  subnet_id      = var.public_subnet_ids[count.index]
  route_table_id = aws_route_table.public[count.index].id
}

# Private Route Tables (per AZ, each with its own NAT Gateway)
resource "aws_route_table" "private" {
  count  = length(var.availability_zones)
  vpc_id = data.aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-private-rt-${count.index + 1}"
    }
  )
}

# Associate private subnets with their corresponding private route table (same AZ)
resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_ids)
  subnet_id      = var.private_subnet_ids[count.index]
  # Route private subnets to the NAT gateway in the same AZ
  route_table_id = aws_route_table.private[count.index % length(var.availability_zones)].id
}

# Data source to get VPC ID
data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["${var.project_name}-vpc"]
  }
}
