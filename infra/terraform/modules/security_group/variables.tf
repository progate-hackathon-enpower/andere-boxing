variable "project_name" {
  description = "Project name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_node_port_from" {
  description = "Start port for public node ingress"
  type        = number
  default     = 7000
}

variable "public_node_port_to" {
  description = "End port for public node ingress"
  type        = number
  default     = 8000
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
