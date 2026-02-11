variable "region" {
  description = "AWS Region"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for ASG"
  type        = list(string)
}

variable "app_sg_id" {
  description = "Security Group ID for WordPress instances"
  type        = string
}

variable "efs_id" {
  description = "The ID of the EFS file system"
  type        = string
}

variable "db_endpoint" {
  description = "The connection endpoint for the RDS instance"
  type        = string
}

variable "db_secret_arn" {
  description = "The ARN of the secret in Secrets Manager"
  type        = string
}

variable "tg_arn" {
  description = "The ARN of the Target Group for the Load Balancer"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for Amazon Linux 2023"
  type        = string
  default     = "ami-0bae57ee7c4478e01" 
}
