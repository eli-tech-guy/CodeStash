provider "aws" {
  region = "us-east-1"
}

locals {
  env                         = terraform.workspace
  lb_name                     = local.env == "production" ? "confluent-lb-production" : "confluent-lb-staging"
  vpc_name                    = local.env == "production" ? "confluent-production" : "confluent-staging"
  workspace_suffix            = local.env == "staging" ? "-staging" : "-production"
  tgw_id                      = "tgw-0681064c35feff4c5"
  confluent_rt_name           = local.env == "production" ? "production-confluent-extraction-rt-private" : "staging-confluent-extraction-rt-private"

  sn_confluent_nlb_1          = "10.162.128.64/28"
  sn_confluent_nlb_2          = "10.162.129.64/28"
  sn_confluent_target_1       = "10.162.128.80/28"
  sn_confluent_target_2       = "10.162.129.80/28"
  
}

resource "aws_vpc" "confluent_extraction" {
  cidr_block       = "10.162.128.0/23"
  instance_tenancy = "default"

  tags = {
    Name = "Production-data-confluent-CC292"
  }
}


resource "aws_subnet" "sn_confluent_nlb_1" {
  vpc_id            = aws_vpc.confluent_extraction.id
  cidr_block        = local.sn_confluent_nlb_1
  availability_zone = "us-east-1a"

  tags = {
    Name = "sn-confluent-nlb-1${local.workspace_suffix}"
  }
}

resource "aws_subnet" "sn_confluent_nlb_2" {
  vpc_id            = aws_vpc.confluent_extraction.id
  cidr_block        = local.sn_confluent_nlb_2
  availability_zone = "us-east-1b"

  tags = {
    Name = "sn-confluent-nlb-2${local.workspace_suffix}"
  }
}

resource "aws_subnet" "sn_confluent_target_1" {
  vpc_id            = aws_vpc.confluent_extraction.id
  cidr_block        = local.sn_confluent_target_1
  availability_zone = "us-east-1a"

  tags = {
    Name = "sn-confluent-target-1${local.workspace_suffix}"
  }
}

resource "aws_subnet" "sn_confluent_target_2" {
  vpc_id            = aws_vpc.confluent_extraction.id
  cidr_block        = local.sn_confluent_target_2
  availability_zone = "us-east-1b"

  tags = {
    Name = "sn-confluent-target-2${local.workspace_suffix}"
  }
}


resource "aws_security_group" "nginx_sg" {
  name        = "nginx-sg${local.workspace_suffix}"
  description = "Allow access to NGINX"
  vpc_id      = aws_vpc.confluent_extraction.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nginx-sg${local.workspace_suffix}"
  }
}


resource "aws_lb" "confluent_nlb_1" {
  name               = "confluent-nlb-1${local.workspace_suffix}"
  internal           = true
  load_balancer_type = "network"
  subnets            = [aws_subnet.sn_confluent_nlb_1.id]

  tags = {
    Name = "confluent-nlb-1${local.workspace_suffix}"
  }
}

resource "aws_lb" "confluent_nlb_2" {
  name               = "confluent-nlb-2${local.workspace_suffix}"
  internal           = true
  load_balancer_type = "network"
  subnets            = [aws_subnet.sn_confluent_nlb_2.id]

  tags = {
    Name = "confluent-nlb-2${local.workspace_suffix}"
  }
}

resource "aws_lb_target_group" "pg_tg_1" {
  name        = "pg-tg-1${local.workspace_suffix}"
  port        = 5432
  protocol    = "TCP"
  vpc_id      = aws_vpc.confluent_extraction.id
  target_type = "ip"

  health_check {
    protocol = "TCP"
    port     = "5432"
  }

  tags = {
    Name = "pg-tg-1${local.workspace_suffix}"
  }
}

resource "aws_lb_target_group_attachment" "pg_target_ip_1" {
  target_group_arn  = aws_lb_target_group.pg_tg_1.arn
  target_id         = "10.162.128.81"
  port              = 5432
  availability_zone = "us-east-1a"
}

resource "aws_lb_target_group" "pg_tg_2" {
  name        = "pg-tg-2${local.workspace_suffix}"
  port        = 5432
  protocol    = "TCP"
  vpc_id      = aws_vpc.confluent_extraction.id
  target_type = "ip"

  health_check {
    protocol = "TCP"
    port     = "5432"
  }

  tags = {
    Name = "pg-tg-2${local.workspace_suffix}"
  }
}

resource "aws_lb_target_group_attachment" "pg_target_ip_2" {
  target_group_arn  = aws_lb_target_group.pg_tg_2.arn
  target_id         = "10.162.129.81"
  port              = 5432
  availability_zone = "us-east-1b"
}

resource "aws_lb_listener" "pg_listener_1" {
  load_balancer_arn = aws_lb.confluent_nlb_1.arn
  port              = 5432
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.pg_tg_1.arn
  }
}

resource "aws_lb_listener" "pg_listener_2" {
  load_balancer_arn = aws_lb.confluent_nlb_2.arn
  port              = 5432
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.pg_tg_2.arn
  }
}

resource "tls_private_key" "ec2_nginx_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ec2_nginx_key_pair" {
  key_name   = "ec2-nginx-key${local.workspace_suffix}"
  public_key = tls_private_key.ec2_nginx_key.public_key_openssh
}

resource "aws_secretsmanager_secret" "ec2_nginx_secret" {
  name        = "ec2-nginx${local.workspace_suffix}.pem"
  description = "Private key for EC2 NGINX SSH access"
}

resource "aws_secretsmanager_secret_version" "ec2_nginx_secret_value" {
  secret_id     = aws_secretsmanager_secret.ec2_nginx_secret.id
  secret_string = tls_private_key.ec2_nginx_key.private_key_pem
}

resource "aws_instance" "nginx_1" {
  ami                         = "ami-0c02fb55956c7d316"
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.sn_confluent_nlb_1.id
  vpc_security_group_ids      = [aws_security_group.nginx_sg.id]
  key_name                    = aws_key_pair.ec2_nginx_key_pair.key_name
  associate_public_ip_address = true

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install nginx1 -y
              systemctl enable nginx
              systemctl start nginx
              EOF

  tags = {
    Name = "nginx-1${local.workspace_suffix}"
  }
}

resource "aws_instance" "nginx_2" {
  ami                         = "ami-0c02fb55956c7d316"
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.sn_confluent_nlb_2.id
  vpc_security_group_ids      = [aws_security_group.nginx_sg.id]
  key_name                    = aws_key_pair.ec2_nginx_key_pair.key_name
  associate_public_ip_address = true

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install nginx1 -y
              systemctl enable nginx
              systemctl start nginx
              EOF

  tags = {
    Name = "nginx-2${local.workspace_suffix}"
  }
}




resource "aws_route_table" "confluent_rt" {
  vpc_id = aws_vpc.confluent_extraction.id

  tags = {
    Name = local.confluent_rt_name
  }
}

resource "aws_route" "confluent_route" {
  route_table_id         = aws_route_table.confluent_rt.id
  destination_cidr_block = terraform.workspace == "staging" ? "10.162.6.0/24" : "10.162.0.0/23"
  transit_gateway_id     = local.tgw_id
}
