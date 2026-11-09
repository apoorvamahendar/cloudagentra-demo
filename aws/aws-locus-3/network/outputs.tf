output "vpc_id" {
  description = "ID of the main VPC"
  value       = aws_vpc.main_vpc.id
}

output "public_subnet_id" {
  description = "ID of the main public subnet"
  value       = aws_subnet.main_public_subnet.id
}

output "internet_gateway_id" {
  description = "ID of the main internet gateway"
  value       = aws_internet_gateway.main_igw.id
}

output "route_table_id" {
  description = "ID of the main public route table"
  value       = aws_route_table.main_public_rt.id
}

output "security_group_id" {
  description = "ID of the main security group"
  value       = aws_security_group.main_sg.id
}

output "elastic_ip" {
  description = "Elastic IP address associated with main-ec2"
  value       = aws_eip.main_eip.public_ip
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i main-keypair.pem ubuntu@${aws_eip.main_eip.public_ip}"
}