# ─────────────────────────────────────────────────────────────────────────────
# Data source: look up the EC2 instance deployed by the 'compute' stack
# so we can associate the EIP with it.
# ─────────────────────────────────────────────────────────────────────────────
data "aws_instance" "web_server_instance" {
  filter {
    name   = "tag:Name"
    values = ["web-server-instance"]
  }

  filter {
    name   = "instance-state-name"
    values = ["running", "pending"]
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# VPC
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_vpc" "web_server_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name  = "web-server-vpc"
    Stack = "network"
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# Subnet
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_subnet" "web_server_public_subnet" {
  vpc_id                  = aws_vpc.web_server_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name  = "web-server-public-subnet"
    Stack = "network"
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# Internet Gateway
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_internet_gateway" "web_server_igw" {
  vpc_id = aws_vpc.web_server_vpc.id

  tags = {
    Name  = "web-server-igw"
    Stack = "network"
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# Route Table (with inline 0.0.0.0/0 → IGW route)
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_route_table" "web_server_public_rt" {
  vpc_id = aws_vpc.web_server_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.web_server_igw.id
  }

  tags = {
    Name  = "web-server-public-rt"
    Stack = "network"
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# Route Table Association
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_route_table_association" "web_server_rta" {
  subnet_id      = aws_subnet.web_server_public_subnet.id
  route_table_id = aws_route_table.web_server_public_rt.id
}

# ─────────────────────────────────────────────────────────────────────────────
# Security Group (shell - rules are managed by separate rule resources)
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_security_group" "web_server_sg" {
  name        = "web-server-sg"
  description = "Security group for web-server-instance: HTTP and SSH inbound, all outbound"
  vpc_id      = aws_vpc.web_server_vpc.id

  tags = {
    Name  = "web-server-sg"
    Stack = "network"
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# Ingress rule - HTTP (TCP 80) from anywhere
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_vpc_security_group_ingress_rule" "web_server_sg_http" {
  security_group_id = aws_security_group.web_server_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  description       = "Allow inbound HTTP from anywhere"

  tags = {
    Name  = "web-server-sg-http-inbound"
    Stack = "network"
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# Ingress rule - SSH (TCP 22) from anywhere
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_vpc_security_group_ingress_rule" "web_server_sg_ssh" {
  security_group_id = aws_security_group.web_server_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  description       = "Allow inbound SSH from anywhere"

  tags = {
    Name  = "web-server-sg-ssh-inbound"
    Stack = "network"
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# Egress rule - all traffic to anywhere
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_vpc_security_group_egress_rule" "web_server_sg_egress" {
  security_group_id = aws_security_group.web_server_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "Allow all outbound traffic"

  tags = {
    Name  = "web-server-sg-all-outbound"
    Stack = "network"
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# Elastic IP - allocated in VPC scope, associated with the compute-stack instance
# depends_on IGW ensures the gateway exists before association
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_eip" "web_server_eip" {
  domain   = "vpc"
  instance = data.aws_instance.web_server_instance.id

  depends_on = [aws_internet_gateway.web_server_igw]

  tags = {
    Name  = "web-server-eip"
    Stack = "network"
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# Outputs
# ─────────────────────────────────────────────────────────────────────────────
output "vpc_id" {
  description = "ID of the web-server VPC"
  value       = aws_vpc.web_server_vpc.id
}

output "subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.web_server_public_subnet.id
}

output "internet_gateway_id" {
  description = "ID of the internet gateway"
  value       = aws_internet_gateway.web_server_igw.id
}

output "route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.web_server_public_rt.id
}

output "security_group_id" {
  description = "ID of the web-server security group"
  value       = aws_security_group.web_server_sg.id
}

output "eip_allocation_id" {
  description = "Allocation ID of the Elastic IP"
  value       = aws_eip.web_server_eip.allocation_id
}

output "public_ip" {
  description = "Public IP address of the web-server instance"
  value       = aws_eip.web_server_eip.public_ip
}

output "ssh_command" {
  description = "SSH command to connect to the web-server instance"
  value       = "ssh -i web-server-key.pem ubuntu@${aws_eip.web_server_eip.public_ip}"
}