provider "aws" {
  region = "us-east-1"
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "docker_host" {
  ami                    = "ami-0c55b159cbfafe1f0" # Amazon Linux 2
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.deployer.key_name
  associate_public_ip_address = true

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y python3"
    ]
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("~/.ssh/id_rsa")
      host        = self.public_ip
    }
  }

  tags = {
    Name = "DockerHost"
  }
}

output "instance_ip" {
  value = aws_instance.docker_host.public_ip
}