provider "aws" {
  region = "us-east-1"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.94.1"
    }

    confluent = {
      source  = "confluentinc/confluent"
      version = "~> 1.59.0"
    }
  }
}

data "aws_secretsmanager_secret_version" "confluent_api_version" {
  secret_id = data.aws_secretsmanager_secret.confluent_api.id
}

data "aws_secretsmanager_secret" "confluent_api" {
  name = "confluent/terraform/apikey"
}

data "aws_security_group" "default" {
  filter {
    name   = "group-name"
    values = ["default"]
  }

  vpc_id = aws_vpc.onehouse.id
}

locals {
  env_suffix = terraform.workspace == "production" ? "-production" : "-staging"

  vpc_cidr_block         = terraform.workspace == "production" ? "10.162.80.0/21" : "10.162.88.0/21"
  public_subnet_1_cidr   = terraform.workspace == "production" ? "10.162.80.0/24" : "10.162.88.0/24"
  public_subnet_2_cidr   = terraform.workspace == "production" ? "10.162.81.0/24" : "10.162.89.0/24"
  private_subnet_1_cidr  = terraform.workspace == "production" ? "10.162.86.0/28" : "10.162.94.0/28"
  private_subnet_2_cidr  = terraform.workspace == "production" ? "10.162.87.0/28" : "10.162.95.0/28"
  confluent_creds = jsondecode(data.aws_secretsmanager_secret_version.confluent_api_version.secret_string)
}

provider "confluent" {
  cloud_api_key    = ""
  cloud_api_secret = ""
}

resource "aws_vpc" "onehouse" {
  cidr_block           = local.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${local.env_suffix}-data-onehouse"
  }
}

resource "aws_internet_gateway" "onehouse_igw" {
  vpc_id = aws_vpc.onehouse.id

  tags = {
    Name = "onehouse-igw${local.env_suffix}"
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.onehouse.id
  cidr_block              = local.public_subnet_1_cidr
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "public-subnet-1${local.env_suffix}"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.onehouse.id
  cidr_block              = local.public_subnet_2_cidr
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"

  tags = {
    Name = "public-subnet-2${local.env_suffix}"
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.onehouse.id
  cidr_block        = local.private_subnet_1_cidr
  availability_zone = "us-east-1a"

  tags = {
    Name = "private-subnet-1${local.env_suffix}"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.onehouse.id
  cidr_block        = local.private_subnet_2_cidr
  availability_zone = "us-east-1b"

  tags = {
    Name = "private-subnet-2${local.env_suffix}"
  }
}

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "onehouse-nat-eip${local.env_suffix}"
  }
}

resource "aws_nat_gateway" "onehouse_nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet_1.id

  tags = {
    Name = "onehouse-nat-gateway${local.env_suffix}"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.onehouse.id

  tags = {
    Name = "public-route-table${local.env_suffix}"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.onehouse.id

  tags = {
    Name = "private-route-table${local.env_suffix}"
  }
}

resource "aws_route" "public_internet_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.onehouse_igw.id
}

resource "aws_route" "private_nat_route" {
  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.onehouse_nat.id
}

resource "aws_route_table_association" "public_subnet_1_assoc" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_subnet_2_assoc" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_subnet_1_assoc" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_subnet_2_assoc" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_rt.id
}



resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.onehouse.id
  service_name      = "com.amazonaws.us-east-1.s3"
  vpc_endpoint_type = "Gateway"

  tags = {
    Name = "Onehouse-endpoint-s3${local.env_suffix}"
  }
}

resource "aws_vpc_endpoint_route_table_association" "s3" {
  route_table_id  = aws_route_table.private_rt.id
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}


resource "aws_ec2_managed_prefix_list" "onehouse_prefix_list" {
  name           = "onehouse-prefix-list${local.env_suffix}"
  address_family = "IPv4"
  max_entries    = 8

  entry {
    cidr        = "16.15.176.0/20"
    description = "CIDR 1"
  }

  entry {
    cidr        = "16.15.192.0/18"
    description = "CIDR 2"
  }

  entry {
    cidr        = "16.182.0.0/16"
    description = "CIDR 3"
  }

  entry {
    cidr        = "18.34.0.0/19"
    description = "CIDR 4"
  }

  entry {
    cidr        = "18.34.232.0/21"
    description = "CIDR 5"
  }

  entry {
    cidr        = "3.5.0.0/19"
    description = "CIDR 6"
  }

  entry {
    cidr        = "52.216.0.0/15"
    description = "CIDR 7"
  }

  entry {
    cidr        = "54.231.0.0/16"
    description = "CIDR 8"
  }

  tags = {
    Name = "onehouse-prefix-list${local.env_suffix}"
  }
}

# resource "aws_vpc_endpoint" "confluent" {
#   vpc_id             = aws_vpc.onehouse.id
#   service_name       = "com.amazonaws.vpce.us-east-1.vpce-svc-03bc1ff023623a033"
#   vpc_endpoint_type  = "Interface"
#   subnet_ids         = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]

#   # Use default security group
#   security_group_ids = [data.aws_security_group.default.id]

#   tags = {
#     Name = "Onehouse-endpoint-confluent${local.env_suffix}"
#   }
# }

# resource "confluent_private_link_attachment_connection" "aws" {
#   display_name = "sc-onehouse-extraction${local.env_suffix}"

#   environment {
#     id = "platt-ezzjv7"
#   }

#   aws {
#     vpc_endpoint_id = aws_vpc_endpoint.confluent.id
#   }

#   private_link_attachment {
#     id = "platt-onehouse"
#   }
# }

# output "private_link_attachment_connection" {
#   value = confluent_private_link_attachment_connection.aws
# }
