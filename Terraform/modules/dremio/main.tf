terraform {
  required_providers {
    dremio = {
      source  = "saltxwater/dremio"
      version = ">=0.3.0"
    }
  }
}

provider "dremio" {
  dremio_url= "https://app.dremio.cloud/sonar/c47597f6-2b0c-4329-802a-dd7e340d972d/source/speedcast-prod"
}

locals {
  dremio_secrets       = jsondecode(data.aws_secretsmanager_secret_version.dremio.secret_string)
  resolved_dremio_token = local.dremio_secrets.dremio_api_token
}

variable "dremio_api_token" {
  description = "Dremio API Token"
  type        = string
  sensitive   = true
}

data "aws_secretsmanager_secret_version" "dremio" {
  secret_id = "dremio-terraform-api-key"
}


output "resolved_dremio_token" {
  value     = local.resolved_dremio_token
  sensitive = true
}


resource "aws_security_group" "imported_sg" {
  name        = "dremio-security-group"
  description = "dremio security group"
  vpc_id      = "vpc-080cafe98dca712ca"

  tags = {
    Name = "dremio-security-group"
  }
}


resource "aws_security_group" "imported_sg_2" {
  name        = "dremio-security-group"
  description = "dremio security group"
  vpc_id      = "vpc-080cafe98dca712ca"

  tags = {
    Name = "dremio-security-group"
  }
}

resource "aws_vpc_endpoint" "dremio_vpce" {
  vpc_id = 	vpc-080cafe98dca712ca
}


resource "dremio_iam_cloud_compute_policy" "iam_policy" {
}

