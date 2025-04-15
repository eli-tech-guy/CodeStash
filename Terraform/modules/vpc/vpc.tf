resource "aws_vpc" "extraction" {
  cidr_block       = terraform.workspace == "staging" ? "10.162.16.0/20" : "10.162.32.0/19"
  instance_tenancy = "default"

  tags = {
    Name = terraform.workspace == "staging" ? "extraction-staging" : "extraction-production"
  }
}

locals {
  sn-mwaa-1-priv-cidr-1           = terraform.workspace == "staging" ? "10.162.23.0/24" : "10.162.47.0/24"
  sn-mwaa-2-priv-cidr-2           = terraform.workspace == "staging" ? "10.162.31.0/24" : "10.162.63.0/24"

  sn-versa-lambda-priv-cidr-1     = terraform.workspace == "staging" ? "10.162.18.16/28" : "10.162.34.0/28"
  sn-versa-lambda-priv-cidr-2     = terraform.workspace == "staging" ? "10.162.26.0/28" : "10.162.50.0/28"

  sn-dialog-lambda-1-priv-cidr-1  = terraform.workspace == "staging" ? "10.162.19.0/24" : "10.162.34.16/28"
  sn-dialog-lambda-2-priv-cidr-2  = terraform.workspace == "staging" ? "10.162.26.16/28" : "10.162.50.16/28"

  sn-tgw-core-1-priv-cidr-1       = terraform.workspace == "staging" ? "10.162.16.0/28" : "10.162.32.0/28"
  sn-tgw-core-2-priv-cidr-2       = terraform.workspace == "staging" ? "10.162.24.0/28" : "10.162.36.0/28"

  sn-privatelink-1-priv-cidr-1    = terraform.workspace == "staging" ? "10.162.16.32/27" : "10.162.32.32/27"
  sn-privatelink-2-priv-cidr-2    = terraform.workspace == "staging" ? "10.162.24.32/27" : "10.162.48.32/27"

  sn-inet-lambda-1-priv-cidr-1    = terraform.workspace == "staging" ? "10.162.22.0/24" : "10.162.44.0/24"
  sn-inet-lambda-2-priv-cidr-2    = terraform.workspace == "staging" ? "10.162.30.0/24" : "10.162.60.0/24"

  sn-ngw-1-pub-1                  = terraform.workspace == "staging" ? "10.162.16.240/28" : "10.162.32.240/28"
  sn-ngw-2-pub-2                  = terraform.workspace == "staging" ? "10.162.24.240/28" : "10.162.48.240/28"

  workspace_suffix                = terraform.workspace == "staging" ? "-staging" : "-production"
  tgw_id                          = "tgw-0681064c35feff4c5"
  timescalert_rt_name             = terraform.workspace == "prod" ? "prod-data-extraction-rt-private" : "staging-data-extraction-rt-private"
}

resource "aws_subnet" "sn-mwaa-1" {
  vpc_id            = aws_vpc.extraction.id
  cidr_block        = local.sn-mwaa-1-priv-cidr-1
  availability_zone = "us-east-1a"

  tags = {
    Name = "sn-mwaa-1${local.workspace_suffix}"
  }
}

resource "aws_subnet" "sn-mwaa-2" {
  vpc_id            = aws_vpc.extraction.id
  cidr_block        = local.sn-mwaa-2-priv-cidr-2
  availability_zone = "us-east-1b"

  tags = {
    Name = "sn-mwaa-2${local.workspace_suffix}"
  }
}

resource "aws_subnet" "sn-versa-lambda-1" {
  vpc_id            = aws_vpc.extraction.id
  cidr_block        = local.sn-versa-lambda-priv-cidr-1
  availability_zone = "us-east-1a"

  tags = {
    Name = "sn-versa-lambda-1${local.workspace_suffix}"
  }
}

resource "aws_subnet" "sn-versa-lambda-2" {
  vpc_id            = aws_vpc.extraction.id
  cidr_block        = local.sn-versa-lambda-priv-cidr-2
  availability_zone = "us-east-1b"

  tags = {
    Name = "sn-versa-lambda-2${local.workspace_suffix}"
  }
}

resource "aws_subnet" "sn-dialog-lambda-1" {
  vpc_id            = aws_vpc.extraction.id
  cidr_block        = local.sn-dialog-lambda-1-priv-cidr-1
  availability_zone = "us-east-1a"

  tags = {
    Name = "sn-dialog-lambda-1${local.workspace_suffix}"
  }
}

resource "aws_subnet" "sn-dialog-lambda-2" {
  vpc_id            = aws_vpc.extraction.id
  cidr_block        = local.sn-dialog-lambda-2-priv-cidr-2
  availability_zone = "us-east-1b"

  tags = {
    Name = "sn-dialog-lambda-2${local.workspace_suffix}"
  }
}

resource "aws_subnet" "sn-tgw-core-1" {
  vpc_id            = aws_vpc.extraction.id
  cidr_block        = local.sn-tgw-core-1-priv-cidr-1
  availability_zone = "us-east-1a"

  tags = {
    Name = "sn-tgw-core-1${local.workspace_suffix}"
  }
}


resource "aws_subnet" "sn-tgw-core-2" {
  vpc_id            = aws_vpc.extraction.id
  cidr_block        = local.sn-tgw-core-2-priv-cidr-2
  availability_zone = "us-east-1b"

  tags = {
    Name = "sn-tgw-core-2${local.workspace_suffix}"
  }
}

resource "aws_subnet" "sn-privatelink-1" {
  vpc_id            = aws_vpc.extraction.id
  cidr_block        = local.sn-privatelink-1-priv-cidr-1
  availability_zone = "us-east-1a"

  tags = {
    Name = "sn-privatelink-1${local.workspace_suffix}"
  }
}

resource "aws_subnet" "sn-privatelink-2" {
  vpc_id            = aws_vpc.extraction.id
  cidr_block        = local.sn-privatelink-2-priv-cidr-2
  availability_zone = "us-east-1b"

  tags = {
    Name = "sn-privatelink-2${local.workspace_suffix}"
  }
}

resource "aws_subnet" "sn-inet-lambda-1" {
  vpc_id            = aws_vpc.extraction.id
  cidr_block        = local.sn-inet-lambda-1-priv-cidr-1
  availability_zone = "us-east-1a"

  tags = {
    Name = "sn-inet-lambda-1${local.workspace_suffix}"
  }
}

resource "aws_subnet" "sn-inet-lambda-2" {
  vpc_id            = aws_vpc.extraction.id
  cidr_block        = local.sn-inet-lambda-2-priv-cidr-2
  availability_zone = "us-east-1b"

  tags = {
    Name = "sn-inet-lambda-2${local.workspace_suffix}"
  }
}

resource "aws_subnet" "sn-ngw-1" {
  vpc_id            = aws_vpc.extraction.id
  cidr_block        = local.sn-ngw-1-pub-1
  availability_zone = "us-east-1a"

  tags = {
    Name = "sn-ngw-1${local.workspace_suffix}"
  }
}



resource "aws_subnet" "sn-ngw-2" {
  vpc_id            = aws_vpc.extraction.id
  cidr_block        = local.sn-ngw-2-pub-2
  availability_zone = "us-east-1b"

  tags = {
    Name = "sn-ngw-2${local.workspace_suffix}"
  }
}



# Define your subnets here (same as before, no changes needed)
# Assume all the aws_subnet resources are already defined above...

resource "aws_internet_gateway" "extraction_igw" {
  vpc_id = aws_vpc.extraction.id

  tags = {
    Name = "extraction-igw${local.workspace_suffix}"
  }
}

resource "aws_eip" "nat_1" {
  domain = "vpc"
  tags = {
    Name = "nat-eip-1${local.workspace_suffix}"
  }
}

resource "aws_eip" "nat_2" {
  domain = "vpc"
  tags = {
    Name = "nat-eip-2${local.workspace_suffix}"
  }
}

resource "aws_nat_gateway" "nat_gw_1" {
  allocation_id = aws_eip.nat_1.id
  subnet_id     = aws_subnet.sn-ngw-1.id
  depends_on    = [aws_internet_gateway.extraction_igw]

  tags = {
    Name = "nat-gw-1${local.workspace_suffix}"
  }
}

resource "aws_nat_gateway" "nat_gw_2" {
  allocation_id = aws_eip.nat_2.id
  subnet_id     = aws_subnet.sn-ngw-2.id
  depends_on    = [aws_internet_gateway.extraction_igw]

  tags = {
    Name = "nat-gw-2${local.workspace_suffix}"
  }
}


resource "aws_ec2_transit_gateway_vpc_attachment" "extraction_tgw_attachment" {
  transit_gateway_id = local.tgw_id
  vpc_id             = aws_vpc.extraction.id
  subnet_ids         = [
    aws_subnet.sn-tgw-core-1.id,
    aws_subnet.sn-tgw-core-2.id
  ]

  tags = {
    Name = "extraction${local.workspace_suffix}-tgw-attachment"
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_route_table" "timescalert" {
  vpc_id = aws_vpc.extraction.id

  tags = {
    Name = local.timescalert_rt_name
  }
}


resource "aws_route" "timescalert_route" {
  route_table_id         = aws_route_table.timescalert.id
  destination_cidr_block = terraform.workspace == "staging" ? "10.162.6.0/24" : "10.162.0.0/23"
  transit_gateway_id     = local.tgw_id
}

resource "aws_route" "public_nat_route" {
  route_table_id         = aws_route_table.timescalert.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw_1.id
}
