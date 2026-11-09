output "web_server_instance_id" {
  description = "EC2 instance ID of the web server"
  value       = aws_instance.web_server.id
}

output "web_server_public_ip" {
  description = "Public IP address assigned to the web server instance"
  value       = aws_instance.web_server.public_ip
}

output "web_server_private_ip" {
  description = "Private IP address of the web server instance"
  value       = aws_instance.web_server.private_ip
}

output "web_server_key_pair_name" {
  description = "Name of the AWS key pair registered for the web server"
  value       = aws_key_pair.web_server_kp.key_name
}

output "web_server_ami_id" {
  description = "AMI ID resolved for Ubuntu 22.04 LTS in the target region"
  value       = data.aws_ami.ubuntu_22_04.id
}