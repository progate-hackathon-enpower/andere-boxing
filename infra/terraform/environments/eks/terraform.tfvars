aws_region          = "ap-northeast-1"
environment         = "staging"
project_name        = "andere-boxing"

# EKS Configuration
kubernetes_version  = "1.29"
node_instance_types = ["t2.small"]
capacity_type       = "SPOT"  # ハッカソンなのでコスト削減のためSPOT

# Private node group (2 nodes)
private_node_desired_size = 2
private_node_min_size     = 1
private_node_max_size     = 3

# Public node group (2 nodes)
public_node_desired_size = 2
public_node_min_size     = 1
public_node_max_size     = 3
