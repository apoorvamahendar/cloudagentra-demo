# ---------------------------------------------------------------------------
# Data sources - look up already-deployed compute resources
# ---------------------------------------------------------------------------
data "aws_instance" "main_ec2" {
  filter {
    name   = "tag:Name"
    values = ["main-ec2"]
  }

  filter {
    name   = "instance-state-name"
    values = ["running", "stopped", "pending"]
  }
}

# ---------------------------------------------------------------------------
# VPC
# ---------------------------------------------------------------------------
resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name  = "main-vpc"
    Stack = "network"
  }
}

# ---------------------------------------------------------------------------
# Public Subnet
# ---------------------------------------------------------------------------
resource "aws_subnet" "main_public_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name  = "main-public-subnet"
    Stack = "network"
  }
}

# ---------------------------------------------------------------------------
# Internet Gateway
# ---------------------------------------------------------------------------
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name  = "main-igw"
    Stack = "network"
  }
}

# ---------------------------------------------------------------------------
# Route Table
# ---------------------------------------------------------------------------
resource "aws_route_table" "main_public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }

  tags = {
    Name  = "main-public-rt"
    Stack = "network"
  }
}

# ---------------------------------------------------------------------------
# Route Table Association
# ---------------------------------------------------------------------------
resource "aws_route_table_association" "main_public_rt_assoc" {
  subnet_id      = aws_subnet.main_public_subnet.id
  route_table_id = aws_route_table.main_public_rt.id
}

# ---------------------------------------------------------------------------
# Security Group
# ---------------------------------------------------------------------------
resource "aws_security_group" "main_sg" {
  name   = "main-sg"
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name  = "main-sg"
    Stack = "network"
  }
}

resource "aws_vpc_security_group_ingress_rule" "main_sg_ingress_ssh" {
  security_group_id = aws_security_group.main_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"

  tags = {
    Name  = "main-sg-ingress-ssh"
    Stack = "network"
  }
}

resource "aws_vpc_security_group_ingress_rule" "main_sg_ingress_http" {
  security_group_id = aws_security_group.main_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"

  tags = {
    Name  = "main-sg-ingress-http"
    Stack = "network"
  }
}

resource "aws_vpc_security_group_egress_rule" "main_sg_egress_all" {
  security_group_id = aws_security_group.main_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"

  tags = {
    Name  = "main-sg-egress-all"
    Stack = "network"
  }
}

# ---------------------------------------------------------------------------
# Elastic IP - associated with the already-deployed EC2 instance
# ---------------------------------------------------------------------------
resource "aws_eip" "main_eip" {
  domain   = "vpc"
  instance = data.aws_instance.main_ec2.id

  depends_on = [aws_internet_gateway.main_igw]

  tags = {
    Name  = "main-eip"
    Stack = "network"
  }
}