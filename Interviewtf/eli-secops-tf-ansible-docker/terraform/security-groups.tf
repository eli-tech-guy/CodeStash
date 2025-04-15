resource "aws_security_group" "secops-reptool-dmz-jump-01-sg" {
  name        = "secops-reptool-dmz-jump-01-sg"
  description = "secops-reptool-dmz-jump-01-sg-desc"
  vpc_id      = "${aws_vpc.secops-reptool-vpc.id}"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["213.86.153.192/26"]
  }

  egress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 3128
    to_port         = 3128
    protocol        = "tcp"
    cidr_blocks     = ["10.0.1.0/24"]
  }

  tags {
    Name = "secops-reptool-dmz-jump-01-sg"
  }

}

resource "aws_security_group" "secops-reptool-dmz-gateway-01-sg" {
  name        = "secops-reptool-dmz-gateway-01-sg"
  description = "secops-reptool-dmz-gateway-01-sg-desc"
  vpc_id      = "${aws_vpc.secops-reptool-vpc.id}"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    security_groups = ["${aws_security_group.secops-reptool-dmz-jump-01-sg.id}"]
  }

  ingress {
    from_port = 3128
    to_port   = 3128
    protocol  = "tcp"
    cidr_blocks     = ["10.0.0.0/22"]
  }

  egress {
    from_port  = 0
    to_port    = 0
    protocol   = -1
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags {
    Name = "secops-reptool-dmz-gateway-01-sg"
  }

}

resource "aws_security_group" "secops-reptool-prod-app-01-sg" {
  name        = "secops-reptool-prod-app-01-sg"
  description = "secops-reptool-prod-app-01-sg-desc"
  vpc_id      = "${aws_vpc.secops-reptool-vpc.id}"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    security_groups = ["${aws_security_group.secops-reptool-dmz-jump-01-sg.id}"]
  }

  egress {
    from_port = 3128
    to_port   = 3128
    protocol  = "tcp"
    security_groups = ["${aws_security_group.secops-reptool-dmz-gateway-01-sg.id}"]
  }

  tags {
    Name = "secops-reptool-prod-app-01-sg"
  }

}
