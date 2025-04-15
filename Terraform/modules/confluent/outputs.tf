output "nginx_ec2_private_key_secret_name" {
  value = aws_secretsmanager_secret.ec2_nginx_secret.name
}
