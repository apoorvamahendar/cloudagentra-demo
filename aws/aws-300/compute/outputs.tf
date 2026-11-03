output "ec2_instance_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.ec2_public_instance.id
}

output "ec2_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.ec2_public_instance.public_ip
}

output "ec2_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.ec2_public_instance.public_dns
}

output "ec2_key_pair_name" {
  description = "Name of the AWS key pair registered for SSH access"
  value       = aws_key_pair.ec2_key_pair.key_name
}

output "ssh_command" {
  description = "SSH command to connect to the EC2 instance"
  value       = "ssh -i ec2-key-pair.pem ubuntu@${aws_instance.ec2_public_instance.public_ip}"
}

output "private_key_pem_path" {
  description = "Path to the downloaded private key file"
  value       = local_sensitive_file.ec2_private_key_pem.filename
}