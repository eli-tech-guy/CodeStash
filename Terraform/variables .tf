variable "db_name" {
  description = "The name of the PostgreSQL database"
  type        = string
  default     = "exampledb"
}

variable "db_username" {
  description = "The username for the PostgreSQL database"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "The password for the PostgreSQL database"
  type        = string
  default     = "strongpassword123"
}

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}
