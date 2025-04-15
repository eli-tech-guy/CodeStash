output "private_key_pem" {
  value       = tls_private_key.generated_key.private_key_pem
  sensitive   = true
  description = "The PEM private key generated for EC2 SSH access"
}

output "ec2_instance_id" {
  value = aws_instance.data_extraction.id
}

output "secret_name" {
  value = aws_secretsmanager_secret.pem_secret.name
}
