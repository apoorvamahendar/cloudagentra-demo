# ============================================================
# aws_vpc - web-server-vpc
# ============================================================
resource "aws_vpc" "web_server_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name  = "web-server-vpc"
    Stack = "network"
  }
}

# ============================================================
# aws_subnet - web-server-public-subnet
# ============================================================
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

# ============================================================
# aws_internet_gateway - web-server-igw
# ============================================================
resource "aws_internet_gateway" "web_server_igw" {
  vpc_id = aws_vpc.web_server_vpc.id

  tags = {
    Name  = "web-server-igw"
    Stack = "network"
  }
}

# ============================================================
# aws_route_table - web-server-public-rtb
# ============================================================
resource "aws_route_table" "web_server_public_rtb" {
  vpc_id = aws_vpc.web_server_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.web_server_igw.id
  }

  tags = {
    Name  = "web-server-public-rtb"
    Stack = "network"
  }
}

# ============================================================
# aws_route_table_association - web-server-public-rtb-association
# ============================================================
resource "aws_route_table_association" "web_server_rtb_association" {
  subnet_id      = aws_subnet.web_server_public_subnet.id
  route_table_id = aws_route_table.web_server_public_rtb.id
}

# ============================================================
# aws_security_group - web-server-sg
# ============================================================
resource "aws_security_group" "web_server_sg" {
  name        = "web-server-sg"
  description = "Allow inbound SSH and HTTP; allow all outbound"
  vpc_id      = aws_vpc.web_server_vpc.id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "web-server-sg"
    Stack = "network"
  }
}

# ============================================================
# Outputs - consumed by the compute stack via data sources
# ============================================================
output "vpc_id" {
  description = "ID of the web-server VPC"
  value       = aws_vpc.web_server_vpc.id
}

output "public_subnet_id" {
  description = "ID of the web-server public subnet"
  value       = aws_subnet.web_server_public_subnet.id
}

output "internet_gateway_id" {
  description = "ID of the web-server Internet Gateway"
  value       = aws_internet_gateway.web_server_igw.id
}

output "route_table_id" {
  description = "ID of the web-server public route table"
  value       = aws_route_table.web_server_public_rtb.id
}

output "security_group_id" {
  description = "ID of the web-server security group"
  value       = aws_security_group.web_server_sg.id
}