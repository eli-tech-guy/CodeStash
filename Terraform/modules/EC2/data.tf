data "aws_vpc" "extraction" {
  filter {
    name   = "tag:Name"
    values = ["extraction-${terraform.workspace}"]
  }
}

data "aws_subnet" "sn_ngw_1" {
  filter {
    name   = "tag:Name"
    values = ["sn-ngw-1-${terraform.workspace}"]
  }

  vpc_id = data.aws_vpc.extraction.id
}

data "aws_security_group" "default" {
  filter {
    name   = "group-name"
    values = ["default"]
  }

  vpc_id = data.aws_vpc.extraction.id
}

data "aws_route_table" "timescalert" {
  filter {
    name   = "tag:Name"
    values = ["timescalert-${terraform.workspace}"]
  }

  vpc_id = data.aws_vpc.extraction.id
}