variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.29"
}

variable "node_instance_types" {
  description = "Instance types for node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "capacity_type" {
  description = "Capacity type for node group (ON_DEMAND or SPOT)"
  type        = string
  default     = "ON_DEMAND"
}

# Private node group scaling
variable "private_node_desired_size" {
  description = "Desired number of private nodes"
  type        = number
  default     = 2
}

variable "private_node_min_size" {
  description = "Minimum number of private nodes"
  type        = number
  default     = 1
}

variable "private_node_max_size" {
  description = "Maximum number of private nodes"
  type        = number
  default     = 3
}

# Public node group scaling
variable "public_node_desired_size" {
  description = "Desired number of public nodes"
  type        = number
  default     = 2
}

variable "public_node_min_size" {
  description = "Minimum number of public nodes"
  type        = number
  default     = 1
}

variable "public_node_max_size" {
  description = "Maximum number of public nodes"
  type        = number
  default     = 3
}

# Public node security group ports
variable "public_node_port_from" {
  description = "Start port for public node ingress (UDP)"
  type        = number
  default     = 7000
}

variable "public_node_port_to" {
  description = "End port for public node ingress (UDP)"
  type        = number
  default     = 8000
}
