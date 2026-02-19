variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "cluster_security_group_id" {
  description = "Security group ID for EKS cluster"
  type        = string
}

variable "private_node_security_group_id" {
  description = "Security group ID for private node group"
  type        = string
}

variable "public_node_security_group_id" {
  description = "Security group ID for public node group"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for EKS cluster (control plane)"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for EKS node group"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for EKS node group"
  type        = list(string)
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

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
