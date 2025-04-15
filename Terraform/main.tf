terraform {
  required_providers {
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "~> 1.17.1"
    }
    timescale = {
      source  = "timescale/timescale"
      version = ">=1.9.0"
    }
    dremio = {
      source  = "saltxwater/dremio"
      version = ">=0.3.0"
    }
    confluent = {
      source  = "confluentinc/confluent"
      version = "2.16.0"
    }
  }
}

#module "dremio" {
#  source = "./modules/dremio"
#}

#module "timescale" {
#  source = "./modules/timescale"
#}

#module "confluent" {
#  source = "./modules/confluent"
#}

#module "vpc" {
# source = "./modules/vpc"
#}

#module "EC2" {
#  source = "./modules/EC2"
#}

#module "S3" {
#  source = "./modules/S3"
#}

module "Onehouse" {
  source = "./modules/Onehouse"
}


resource "aws_s3_bucket" "terraformstate" {
  bucket = "terraform-speedcast-state"
  acl    = "private"
  tags = {
    Name        = "terraform-speedcast-state"
    Environment = "Terraform"
  }
}


resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "TerraformLocksTable"
    Environment = "Terraform"
  }
}



