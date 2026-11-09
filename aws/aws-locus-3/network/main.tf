# ─────────────────────────────────────────────
# Data sources
# ─────────────────────────────────────────────

# Resolve the latest Ubuntu 22.04 LTS AMI in ap-south-1
data "aws_ami" "ubuntu_22_04" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# Look up the key pair already created by the compute stack
data "aws_key_pair" "ubuntu_web_key" {
  key_name = "ubuntu-web-key"
}

# ─────────────────────────────────────────────
# VPC
# ─────────────────────────────────────────────

resource "aws_vpc" "ubuntu_web_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name  = "ubuntu-web-vpc"
    Stack = "network"
  }
}

# ─────────────────────────────────────────────
# Public Subnet
# ─────────────────────────────────────────────

resource "aws_subnet" "ubuntu_web_subnet_public" {
  vpc_id                  = aws_vpc.ubuntu_web_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name  = "ubuntu-web-subnet-public"
    Stack = "network"
  }
}

# ─────────────────────────────────────────────
# Internet Gateway
# ─────────────────────────────────────────────

resource "aws_internet_gateway" "ubuntu_web_igw" {
  vpc_id = aws_vpc.ubuntu_web_vpc.id

  tags = {
    Name  = "ubuntu-web-igw"
    Stack = "network"
  }
}

# ─────────────────────────────────────────────
# Route Table
# ─────────────────────────────────────────────

resource "aws_route_table" "ubuntu_web_rtb_public" {
  vpc_id = aws_vpc.ubuntu_web_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ubuntu_web_igw.id
  }

  tags = {
    Name  = "ubuntu-web-rtb-public"
    Stack = "network"
  }
}

# ─────────────────────────────────────────────
# Route Table Association
# ─────────────────────────────────────────────

resource "aws_route_table_association" "ubuntu_web_rtb_assoc" {
  subnet_id      = aws_subnet.ubuntu_web_subnet_public.id
  route_table_id = aws_route_table.ubuntu_web_rtb_public.id
}

# ─────────────────────────────────────────────
# Security Group (shell - rules managed separately)
# ─────────────────────────────────────────────

resource "aws_security_group" "ubuntu_web_sg" {
  name        = "ubuntu-web-sg"
  description = "Allow HTTP and SSH inbound; all outbound"
  vpc_id      = aws_vpc.ubuntu_web_vpc.id

  tags = {
    Name  = "ubuntu-web-sg"
    Stack = "network"
  }
}

# Inbound - HTTP (port 80)
resource "aws_vpc_security_group_ingress_rule" "ubuntu_web_sg_ingress_http" {
  security_group_id = aws_security_group.ubuntu_web_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  description       = "Allow HTTP from anywhere"

  tags = {
    Name  = "ubuntu-web-sg-ingress-http"
    Stack = "network"
  }
}

# Inbound - SSH (port 22)
resource "aws_vpc_security_group_ingress_rule" "ubuntu_web_sg_ingress_ssh" {
  security_group_id = aws_security_group.ubuntu_web_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  description       = "Allow SSH from anywhere"

  tags = {
    Name  = "ubuntu-web-sg-ingress-ssh"
    Stack = "network"
  }
}

# Outbound - all traffic
resource "aws_vpc_security_group_egress_rule" "ubuntu_web_sg_egress_all" {
  security_group_id = aws_security_group.ubuntu_web_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "Allow all outbound traffic"

  tags = {
    Name  = "ubuntu-web-sg-egress-all"
    Stack = "network"
  }
}

# ─────────────────────────────────────────────
# EC2 Instance
# ─────────────────────────────────────────────

resource "aws_instance" "ubuntu_web_server" {
  ami                    = data.aws_ami.ubuntu_22_04.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.ubuntu_web_subnet_public.id
  vpc_security_group_ids = [aws_security_group.ubuntu_web_sg.id]
  key_name               = data.aws_key_pair.ubuntu_web_key.key_name

  depends_on = [
    aws_internet_gateway.ubuntu_web_igw,
    aws_route_table_association.ubuntu_web_rtb_assoc,
  ]

  tags = {
    Name  = "ubuntu-web-server"
    Stack = "network"
  }
}

# ─────────────────────────────────────────────
# Elastic IP
# ─────────────────────────────────────────────

resource "aws_eip" "ubuntu_web_eip" {
  domain   = "vpc"
  instance = aws_instance.ubuntu_web_server.id

  depends_on = [aws_internet_gateway.ubuntu_web_igw]

  tags = {
    Name  = "ubuntu-web-eip"
    Stack = "network"
  }
}

# ─────────────────────────────────────────────
# Outputs
# ─────────────────────────────────────────────

output "vpc_id" {
  description = "ID of the ubuntu-web-vpc VPC"
  value       = aws_vpc.ubuntu_web_vpc.id
}

output "subnet_id" {
  description = "ID of the ubuntu-web-subnet-public subnet"
  value       = aws_subnet.ubuntu_web_subnet_public.id
}

output "internet_gateway_id" {
  description = "ID of the ubuntu-web-igw internet gateway"
  value       = aws_internet_gateway.ubuntu_web_igw.id
}

output "security_group_id" {
  description = "ID of the ubuntu-web-sg security group"
  value       = aws_security_group.ubuntu_web_sg.id
}

output "instance_id" {
  description = "Instance ID of ubuntu-web-server"
  value       = aws_instance.ubuntu_web_server.id
}

output "public_ip" {
  description = "Public IP address of ubuntu-web-server (via Elastic IP)"
  value       = aws_eip.ubuntu_web_eip.public_ip
}

output "ssh_command" {
  description = "SSH command to connect to ubuntu-web-server"
  value       = "ssh -i ubuntu-web-key.pem ubuntu@${aws_eip.ubuntu_web_eip.public_ip}"
}