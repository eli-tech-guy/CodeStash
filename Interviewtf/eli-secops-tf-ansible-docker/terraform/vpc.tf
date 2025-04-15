resource "aws_vpc" "secops-reptool-vpc" {
  cidr_block = "10.0.0.0/16"
  tags {
    Name = "secops-reptool-vpc"
  }
}
