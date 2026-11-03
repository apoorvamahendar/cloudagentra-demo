output "vpc_id" {
  description = "ID of the public VPC"
  value       = aws_vpc.ec2_public_vpc.id
}

output "subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.ec2_public_subnet.id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.ec2_public_igw.id
}

output "route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.ec2_public_rtb.id
}

output "security_group_id" {
  description = "ID of the EC2 public security group"
  value       = aws_security_group.ec2_public_sg.id
}