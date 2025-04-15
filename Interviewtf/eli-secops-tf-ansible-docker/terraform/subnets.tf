resource "aws_subnet" "secops-reptool-dmz" {
  vpc_id     = "${aws_vpc.secops-reptool-vpc.id}"
  cidr_block = "10.0.1.0/24"

  tags {
    Name = "secops-reptool-dmz"
  }
}

resource "aws_subnet" "secops-reptool-prod" {
  vpc_id     = "${aws_vpc.secops-reptool-vpc.id}"
  cidr_block = "10.0.2.0/24"

  tags {
    Name = "secops-reptool-prod"
  }
}

####
## Simply NACL to prevent accidental SG changes allowing anything more than SSH from the DMZ to prod.

resource "aws_network_acl" "secops-reptool-prod-nacl" {
  vpc_id = "${aws_vpc.secops-reptool-vpc.id}"
  subnet_id = "${aws_subnet.secops-reptool-prod.id}"

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.0.1.0/24"
    from_port  = 22
    to_port    = 22
  }
  ingress {
    protocol   = "tcp"
    rule_no    = 103
    action     = "allow"
    cidr_block = "10.0.1.0/24"
    from_port  = 3128
    to_port    = 3128
  }
  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags {
    Name = "secops-reptool-prod-nacl"
  }
}
