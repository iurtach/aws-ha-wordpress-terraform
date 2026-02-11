variable "asg_name" {}
variable "region"   {}
variable "db_instance_identifier" {
  description = "The identifier for the RDS instance"
  type        = string
}
