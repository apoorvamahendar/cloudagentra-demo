output "ec2_key_pair_name" {
  description = "Name of the AWS key pair registered for the EC2 instance."
  value       = aws_key_pair.ec2_key_pair.key_name
}

output "ec2_instance_id" {
  description = "ID of the deployed EC2 instance."
  value       = aws_instance.web_instance.id
}

output "ec2_instance_public_ip" {
  description = "Public IP address assigned to the EC2 instance."
  value       = aws_instance.web_instance.public_ip
}

output "ec2_instance_public_dns" {
  description = "Public DNS hostname of the EC2 instance."
  value       = aws_instance.web_instance.public_dns
}

output "ssh_command" {
  description = "SSH command to connect to the instance using the generated key."
  value       = "ssh -i ec2-private-key.pem ubuntu@${aws_instance.web_instance.public_ip}"
}

output "private_key_pem_path" {
  description = "Local path to the generated PEM private key file."
  value       = local_sensitive_file.private_key_file.filename
  sensitive   = true
}

# ---------------------------------------------------------------------------
# Outputs for the new plan resources
# ---------------------------------------------------------------------------

output "web_ec2_key_pair_new_name" {
  description = "Name of the new AWS key pair for the web-ec2-key instance."
  value       = aws_key_pair.web_ec2_key_pair_new.key_name
}

output "web_ec2_instance_new_id" {
  description = "ID of the newly deployed web EC2 instance."
  value       = aws_instance.web_ec2_instance_new.id
}

output "web_ec2_instance_new_public_ip" {
  description = "Elastic IP address associated with the new web EC2 instance."
  value       = aws_eip.web_ec2_eip.public_ip
}

output "web_ec2_instance_new_public_dns" {
  description = "Public DNS hostname of the new web EC2 instance."
  value       = aws_instance.web_ec2_instance_new.public_dns
}

output "web_ec2_ssh_command" {
  description = "SSH command to connect to the new web EC2 instance."
  value       = "ssh -i web-ec2-key.pem ubuntu@${aws_eip.web_ec2_eip.public_ip}"
}

output "web_ec2_key_new_pem_path" {
  description = "Local path to the new web-ec2-key PEM private key file."
  value       = local_sensitive_file.web_ec2_key_new_pem.filename
  sensitive   = true
}