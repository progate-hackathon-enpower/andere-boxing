# EKS Cluster Security Group
resource "aws_security_group" "eks_cluster" {
  name        = "${var.project_name}-eks-cluster-sg"
  description = "Security group for EKS cluster"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-eks-cluster-sg"
    }
  )
}

# Private Node Group Security Group
resource "aws_security_group" "eks_private_node" {
  name        = "${var.project_name}-eks-private-node-sg"
  description = "Security group for EKS private node group"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow cluster to communicate with nodes"
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_cluster.id]
  }

  ingress {
    description = "Allow private nodes to communicate with each other"
    from_port   = 0
    to_port     = 65535
    protocol    = "-1"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-eks-private-node-sg"
    }
  )
}

# Public Node Group Security Group
resource "aws_security_group" "eks_public_node" {
  name        = "${var.project_name}-eks-public-node-sg"
  description = "Security group for EKS public node group"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow cluster to communicate with nodes"
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_cluster.id]
  }

  ingress {
    description = "Allow public nodes to communicate with each other"
    from_port   = 0
    to_port     = 65535
    protocol    = "-1"
    self        = true
  }

  ingress {
    description = "Allow application ports from internet (UDP)"
    from_port   = var.public_node_port_from
    to_port     = var.public_node_port_to
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-eks-public-node-sg"
    }
  )
}

# Allow private and public nodes to communicate with each other
resource "aws_security_group_rule" "private_to_public" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  security_group_id        = aws_security_group.eks_private_node.id
  source_security_group_id = aws_security_group.eks_public_node.id
  description              = "Allow public nodes to communicate with private nodes"
}

resource "aws_security_group_rule" "public_to_private" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  security_group_id        = aws_security_group.eks_public_node.id
  source_security_group_id = aws_security_group.eks_private_node.id
  description              = "Allow private nodes to communicate with public nodes"
}

# Allow cluster to receive from private nodes
resource "aws_security_group_rule" "cluster_from_private_nodes" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster.id
  source_security_group_id = aws_security_group.eks_private_node.id
  description              = "Allow private nodes to communicate with cluster API"
}

# Allow cluster to receive from public nodes
resource "aws_security_group_rule" "cluster_from_public_nodes" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster.id
  source_security_group_id = aws_security_group.eks_public_node.id
  description              = "Allow public nodes to communicate with cluster API"
}
