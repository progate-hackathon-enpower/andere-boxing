resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-vpc"
    }
  )
}

# Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-public-subnet"
      Type = "Public"
    }
  )
}

# Private Subnet for EKS
resource "aws_subnet" "eks" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_eks_cidr
  availability_zone = var.availability_zone

  tags = merge(
    var.tags,
    {
      Name                                          = "${var.project_name}-private-eks"
      Type                                          = "Private"
      "kubernetes.io/role/elb"                      = "1"
      "kubernetes.io/cluster/${var.project_name}"   = "owned"
    }
  )
}

# Private Subnet for ECR/Observability
resource "aws_subnet" "observability" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_observability_cidr
  availability_zone = var.availability_zone

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-private-observability"
      Type = "Private"
    }
  )
}

# Private Subnet for Lambda
resource "aws_subnet" "lambda" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_lambda_cidr
  availability_zone = var.availability_zone

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-private-lambda"
      Type = "Private"
    }
  )
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-igw"
    }
  )
}
