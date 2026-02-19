aws_region  = "ap-northeast-1"
environment = "staging"
project_name = "andere-boxing"

# ECR Configuration
ecr_repository_names = ["tanstack-web","sync-server"]
ecr_image_tag_mutability = "IMMUTABLE"
ecr_scan_on_push = true
ecr_retention_days = 30
