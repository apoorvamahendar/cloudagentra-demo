# ─────────────────────────────────────────────
# VPC
# ─────────────────────────────────────────────
resource "aws_vpc" "vpc111" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name  = "vpc111"
    Stack = "network"
  }
}

# ─────────────────────────────────────────────
# Public Subnet
# ─────────────────────────────────────────────
resource "aws_subnet" "vpc111_public_subnet_1" {
  vpc_id                  = aws_vpc.vpc111.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name  = "vpc111-public-subnet-1"
    Stack = "network"
  }
}

# ─────────────────────────────────────────────
# Internet Gateway
# ─────────────────────────────────────────────
resource "aws_internet_gateway" "vpc111_igw" {
  vpc_id = aws_vpc.vpc111.id

  tags = {
    Name  = "vpc111-igw"
    Stack = "network"
  }
}

# ─────────────────────────────────────────────
# Route Table (public)
# ─────────────────────────────────────────────
resource "aws_route_table" "vpc111_public_rtb" {
  vpc_id = aws_vpc.vpc111.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc111_igw.id
  }

  tags = {
    Name  = "vpc111-public-rtb"
    Stack = "network"
  }
}

# ─────────────────────────────────────────────
# Route Table Association
# ─────────────────────────────────────────────
resource "aws_route_table_association" "vpc111_rtb_association" {
  subnet_id      = aws_subnet.vpc111_public_subnet_1.id
  route_table_id = aws_route_table.vpc111_public_rtb.id
}

# ─────────────────────────────────────────────
# Security Group
# ─────────────────────────────────────────────
resource "aws_security_group" "vpc111_sg" {
  name        = "vpc111-sg"
  description = "Allow SSH and HTTP inbound; all outbound"
  vpc_id      = aws_vpc.vpc111.id

  tags = {
    Name  = "vpc111-sg"
    Stack = "network"
  }
}

resource "aws_vpc_security_group_ingress_rule" "vpc111_sg_ssh" {
  security_group_id = aws_security_group.vpc111_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  description       = "Allow SSH from anywhere"

  tags = {
    Name  = "vpc111-sg-ssh"
    Stack = "network"
  }
}

resource "aws_vpc_security_group_ingress_rule" "vpc111_sg_http" {
  security_group_id = aws_security_group.vpc111_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  description       = "Allow HTTP from anywhere"

  tags = {
    Name  = "vpc111-sg-http"
    Stack = "network"
  }
}

resource "aws_vpc_security_group_egress_rule" "vpc111_sg_all_outbound" {
  security_group_id = aws_security_group.vpc111_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "Allow all outbound traffic"

  tags = {
    Name  = "vpc111-sg-egress-all"
    Stack = "network"
  }
}

# ─────────────────────────────────────────────
# Data source: EC2 instance deployed by compute
# stack (looked up by its Name tag "vpc111-ec2")
# ─────────────────────────────────────────────
data "aws_instance" "vpc111_ec2" {
  filter {
    name   = "tag:Name"
    values = ["vpc111-ec2"]
  }

  filter {
    name   = "instance-state-name"
    values = ["running", "pending"]
  }
}

# ─────────────────────────────────────────────
# Elastic IP - associated with vpc111-ec2
# IGW must exist before EIP association works
# ─────────────────────────────────────────────
resource "aws_eip" "vpc111_eip" {
  domain   = "vpc"
  instance = data.aws_instance.vpc111_ec2.id

  tags = {
    Name  = "vpc111-eip"
    Stack = "network"
  }

  depends_on = [aws_internet_gateway.vpc111_igw]
}

# ─────────────────────────────────────────────
# Outputs
# ─────────────────────────────────────────────
output "vpc_id" {
  description = "ID of vpc111"
  value       = aws_vpc.vpc111.id
}

output "public_subnet_id" {
  description = "ID of vpc111-public-subnet-1"
  value       = aws_subnet.vpc111_public_subnet_1.id
}

output "internet_gateway_id" {
  description = "ID of vpc111-igw"
  value       = aws_internet_gateway.vpc111_igw.id
}

output "route_table_id" {
  description = "ID of vpc111-public-rtb"
  value       = aws_route_table.vpc111_public_rtb.id
}

output "security_group_id" {
  description = "ID of vpc111-sg"
  value       = aws_security_group.vpc111_sg.id
}

output "eip_public_ip" {
  description = "Public IP address of vpc111-eip (associated with vpc111-ec2)"
  value       = aws_eip.vpc111_eip.public_ip
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i vpc111-key.pem ubuntu@${aws_eip.vpc111_eip.public_ip}"
}