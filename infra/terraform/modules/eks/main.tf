# EKS Cluster IAM Role
resource "aws_iam_role" "cluster" {
  name = "${var.project_name}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

# EKS Cluster
resource "aws_eks_cluster" "main" {
  name     = "${var.project_name}-cluster"
  role_arn = aws_iam_role.cluster.arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
    security_group_ids      = [var.cluster_security_group_id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_policy
  ]

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-cluster"
    }
  )
}

# Node Group IAM Role
resource "aws_iam_role" "node_group" {
  name = "${var.project_name}-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_group.name
}

resource "aws_iam_role_policy_attachment" "cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node_group.name
}

resource "aws_iam_role_policy_attachment" "ecr_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node_group.name
}

# Launch Template for Private Node Group
resource "aws_launch_template" "private" {
  name = "${var.project_name}-private-node-lt"

  instance_type          = var.node_instance_types[0]
  vpc_security_group_ids = [var.private_node_security_group_id]

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      var.tags,
      {
        Name = "${var.project_name}-private-node"
      }
    )
  }

  tags = var.tags
}

# Launch Template for Public Node Group
resource "aws_launch_template" "public" {
  name = "${var.project_name}-public-node-lt"

  instance_type          = var.node_instance_types[0]
  vpc_security_group_ids = [var.public_node_security_group_id]

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      var.tags,
      {
        Name = "${var.project_name}-public-node"
      }
    )
  }

  tags = var.tags
}

# EKS Node Group - Private Subnet
resource "aws_eks_node_group" "private" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.project_name}-private-node-group"
  node_role_arn   = aws_iam_role.node_group.arn
  subnet_ids      = var.private_subnet_ids

  capacity_type = var.capacity_type

  launch_template {
    id      = aws_launch_template.private.id
    version = aws_launch_template.private.latest_version
  }

  scaling_config {
    desired_size = var.private_node_desired_size
    max_size     = var.private_node_max_size
    min_size     = var.private_node_min_size
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_policy,
    aws_iam_role_policy_attachment.cni_policy,
    aws_iam_role_policy_attachment.ecr_policy,
  ]

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-private-node-group"
    }
  )
}

# EKS Node Group - Public Subnet
resource "aws_eks_node_group" "public" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.project_name}-public-node-group"
  node_role_arn   = aws_iam_role.node_group.arn
  subnet_ids      = var.public_subnet_ids

  capacity_type = var.capacity_type

  launch_template {
    id      = aws_launch_template.public.id
    version = aws_launch_template.public.latest_version
  }

  scaling_config {
    desired_size = var.public_node_desired_size
    max_size     = var.public_node_max_size
    min_size     = var.public_node_min_size
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_policy,
    aws_iam_role_policy_attachment.cni_policy,
    aws_iam_role_policy_attachment.ecr_policy,
  ]

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-public-node-group"
    }
  )
}
