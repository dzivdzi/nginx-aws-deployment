# variables.tf

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "nginx-deployment"
}

variable "environment" {
  description = "Environment"
  type        = string
  default     = "production"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "min_instances" {
  description = "Minimum number of instances"
  type        = number
  default     = 3
}

variable "max_instances" {
  description = "Maximum number of instances"
  type        = number
  default     = 6
}

variable "certificate_arn" {
  description = "ACM certificate ARN for HTTPS"
  type        = string
}

variable "key_name" {
  description = "EC2 key pair name"
  type        = string
}

variable "private_subnet_count" {
  description = "Number of private subnets for instance distribution"
  type        = number
  default     = 3
}

variable "bastion_allowed_ip" {
  description = "CIDR block allowed to SSH into bastion"
  type        = string
  default     = "0.0.0.0/0" # Change default to your IP or restrict as needed
}
