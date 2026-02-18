variable "public_subnet_cidr" {
  type        = string
  description = "CIDR block for public subnet"
  default     = "10.0.0.0/24"
}

variable "private_subnet_eks_cidr" {
  type        = string
  description = "CIDR block for private EKS subnet"
  default     = "10.0.10.0/23"
}

variable "private_subnet_observability_cidr" {
  type        = string
  description = "CIDR block for private observability subnet"
  default     = "10.0.20.0/23"
}

variable "private_subnet_lambda_cidr" {
  type        = string
  description = "CIDR block for private Lambda subnet"
  default     = "10.0.28.0/22"
}

variable "availability_zone" {
  type        = string
  description = "Availability zone"
}
