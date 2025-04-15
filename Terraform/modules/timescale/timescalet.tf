terraform {
  required_providers {
    timescale = {
      source  = "timescale/timescale"
      version = ">=1.9.0"
    }
  }
}

provider "timescale" {
  project_id = var.ts_project_id
  access_key = var.ts_access_key
  secret_key = var.ts_secret_key
}


data "aws_vpc" "vpc" {
  id = "vpc-061154c0c571ea07d"
}

# resource "timescale_vpcs" "vpcstg" { 
#   cidr        = "192.168.0.0/24"  # Valid /24 range
#   name        = "speedcast-staging"
#   region_code = "us-east-1"
# }

# resource "timescale_peering_connection" "stg" { 
#   peer_account_id  = "891377142936"
#   peer_region_code = "us-east-1"
#   peer_vpc_id      = "vpc-0a1c9d989ad1a10d9"
#   timescale_vpc_id = timescale_vpcs.vpcstg.id
# }

# resource "timescale_vpcs" "vpcprod" { 
#   cidr        = "192.168.0.0/24"  # Valid /24 range
#   name        = "speedcast-prod"
#   region_code = "us-east-1"
# }

# resource "timescale_peering_connection" "prod" { 
#   peer_account_id  = "241533149472"
#   peer_region_code = "us-east-1"
#   peer_vpc_id      = "vpc-081a5d7e8e32a5b27"
#   timescale_vpc_id = timescale_vpcs.vpcprod.id
# }

# resource "timescale_service" "speedcast-stg" {
#   name        = "DB-Staging"
#   milli_cpu   = 16000
#   memory_gb   = 64
#   region_code = "us-east-1"
#   vpc_id      = timescale_vpcs.vpcstg.id
# }

# resource "timescale_service" "speedcast-prod" {
#   name        = "DB-Prod"
#   milli_cpu   = 16000
#   memory_gb   = 64
#   region_code = "us-east-1"
#   vpc_id      = timescale_vpcs.vpcprod.id
# }
