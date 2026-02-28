aws_region                          = "ap-northeast-1"
environment                         = "staging"
project_name                        = "andere-boxing"

# VPC Configuration (Multi-AZ)
vpc_cidr                            = "10.0.0.0/16"
availability_zones                  = ["ap-northeast-1a", "ap-northeast-1c"]
public_subnet_cidrs                 = ["10.0.0.0/24", "10.0.1.0/24"]
private_subnet_eks_cidrs            = ["10.0.10.0/23", "10.0.12.0/23"]
private_subnet_observability_cidrs  = ["10.0.20.0/23", "10.0.22.0/23"]
private_subnet_lambda_cidrs         = ["10.0.28.0/23", "10.0.30.0/23"]

# VPC Flow Logs
vpc_flow_logs_retention_days = 7
