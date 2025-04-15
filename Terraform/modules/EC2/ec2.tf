provider "aws" {
  region = "us-east-1"
}

provider "tls" {}

locals {
  vpc_name = terraform.workspace == "production" ? "extraction-production" : "extraction-staging"
  subnet_name = terraform.workspace == "production" ? "sn-inet-lambda-1-production" : "sn-inet-lambda-1-staging"
}


resource "tls_private_key" "generated_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


resource "aws_key_pair" "generated" {
  key_name   = "generated-key-${terraform.workspace}"
  public_key = tls_private_key.generated_key.public_key_openssh
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}


data "aws_subnet" "lambda_production" {
  filter {
    name   = "tag:Name"
    values = [local.subnet_name]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.extraction.id]
  }
}



resource "aws_instance" "data_extraction" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.xlarge"
  key_name               = aws_key_pair.generated.key_name
  subnet_id = data.aws_subnet.lambda_production.id

  vpc_security_group_ids = [data.aws_security_group.default.id]
  associate_public_ip_address = false

  root_block_device {
    volume_size           = 60
    volume_type           = "gp2"
    delete_on_termination = true
  }

  tags = {
    Name = "data-extraction-${terraform.workspace}"
  }
}


resource "aws_secretsmanager_secret" "pem_secret" {
  name        = "data-extraction-ec2-key-${terraform.workspace}"
  description = "Generated PEM for EC2 data-extraction-${terraform.workspace}"
}

resource "aws_secretsmanager_secret_version" "pem_secret_version" {
  secret_id     = aws_secretsmanager_secret.pem_secret.id
  secret_string = tls_private_key.generated_key.private_key_pem
}

resource "aws_secretsmanager_secret_policy" "allow_access_to_others" {
  secret_arn = aws_secretsmanager_secret.pem_secret.arn

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid      = "AllowOtherUsersToRetrieveSecret",
        Effect   = "Allow",
        Principal = {
          AWS = [
            "*"
          ]
        },
        Action = [
          "secretsmanager:GetSecretValue"
        ],
        Resource = aws_secretsmanager_secret.pem_secret.arn
      }
    ]
  })
}
