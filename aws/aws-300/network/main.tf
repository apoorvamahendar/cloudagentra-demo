# ──────────────────────────────────────────────
# Network stack: VPC, Subnet, IGW, Route Table,
# Route Table Association, Security Group
# Region: ap-south-1
# ──────────────────────────────────────────────

# ── VPC ──────────────────────────────────────
resource "aws_vpc" "ec2_public_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name  = "ec2-public-vpc"
    Stack = "network"
  }
}

# ── Public Subnet ─────────────────────────────
resource "aws_subnet" "ec2_public_subnet" {
  vpc_id                  = aws_vpc.ec2_public_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name  = "ec2-public-subnet"
    Stack = "network"
  }
}

# ── Internet Gateway ──────────────────────────
resource "aws_internet_gateway" "ec2_public_igw" {
  vpc_id = aws_vpc.ec2_public_vpc.id

  tags = {
    Name  = "ec2-public-igw"
    Stack = "network"
  }
}

# ── Route Table ───────────────────────────────
resource "aws_route_table" "ec2_public_rtb" {
  vpc_id = aws_vpc.ec2_public_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ec2_public_igw.id
  }

  tags = {
    Name  = "ec2-public-rtb"
    Stack = "network"
  }
}

# ── Route Table Association ───────────────────
resource "aws_route_table_association" "ec2_public_rtb_assoc" {
  subnet_id      = aws_subnet.ec2_public_subnet.id
  route_table_id = aws_route_table.ec2_public_rtb.id
}

# ── Security Group ────────────────────────────
resource "aws_security_group" "ec2_public_sg" {
  name        = "ec2-public-sg"
  description = "Allow inbound HTTP (80) and SSH (22); unrestricted outbound"
  vpc_id      = aws_vpc.ec2_public_vpc.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "ec2-public-sg"
    Stack = "network"
  }
}