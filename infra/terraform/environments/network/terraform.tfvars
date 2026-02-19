aws_region                          = "ap-northeast-1"
environment                         = "staging"
project_name                        = "andere-boxing"

# VPC Configuration
vpc_cidr                            = "10.0.0.0/16"
public_subnet_cidr                  = "10.0.0.0/24"
private_subnet_eks_cidr             = "10.0.10.0/23"
private_subnet_observability_cidr   = "10.0.20.0/23"
private_subnet_lambda_cidr          = "10.0.28.0/22"
availability_zone                   = "ap-northeast-1a"

# VPC Flow Logs
vpc_flow_logs_retention_days = 7
