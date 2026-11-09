resource "tls_private_key" "ubuntu_web_tls_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ubuntu_web_key" {
  key_name   = "ubuntu-web-key"
  public_key = tls_private_key.ubuntu_web_tls_key.public_key_openssh

  tags = {
    Name  = "ubuntu-web-key"
    Stack = "compute"
  }
}

resource "local_sensitive_file" "ubuntu_web_private_key_pem" {
  content         = tls_private_key.ubuntu_web_tls_key.private_key_pem
  filename        = "${path.module}/ubuntu-web-key.pem"
  file_permission = "0600"
}

output "key_pair_name" {
  description = "Name of the AWS key pair registered for the Ubuntu web instance."
  value       = aws_key_pair.ubuntu_web_key.key_name
}

output "key_pair_id" {
  description = "ID of the AWS key pair."
  value       = aws_key_pair.ubuntu_web_key.key_pair_id
}

output "key_pair_arn" {
  description = "ARN of the AWS key pair."
  value       = aws_key_pair.ubuntu_web_key.arn
}

output "private_key_pem" {
  description = "RSA private key in PEM format - store securely and chmod 0600."
  value       = tls_private_key.ubuntu_web_tls_key.private_key_pem
  sensitive   = true
}

output "ssh_private_key_path" {
  description = "Path to the written PEM file on the apply host."
  value       = local_sensitive_file.ubuntu_web_private_key_pem.filename
}