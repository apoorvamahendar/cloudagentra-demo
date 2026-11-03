output "eip_public_ip" {
  description = "The static Elastic IP address associated with the EC2 instance."
  value       = aws_eip.ec2_public_eip.public_ip
}

output "eip_allocation_id" {
  description = "The allocation ID of the Elastic IP."
  value       = aws_eip.ec2_public_eip.allocation_id
}

output "ssh_command" {
  description = "SSH command to connect to the EC2 instance via the Elastic IP."
  value       = "ssh -i ec2-key-pair.pem ubuntu@${aws_eip.ec2_public_eip.public_ip}"
}