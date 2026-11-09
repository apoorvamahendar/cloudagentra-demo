# ─── Data sources ────────────────────────────────────────────────────────────

# Resolve the latest Ubuntu 22.04 LTS AMI published by Canonical
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
}

# Look up the already-deployed key pair (created by the 'compute' stack)
data "aws_key_pair" "ubuntu_web_key" {
  key_name = "ubuntu-web-key"
}

# ─── VPC ─────────────────────────────────────────────────────────────────────

resource "aws_vpc" "ubuntu_web_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name  = "ubuntu-web-vpc"
    Stack = "network"
  }
}

# ─── Public subnet ───────────────────────────────────────────────────────────

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

# ─── Internet Gateway ────────────────────────────────────────────────────────

resource "aws_internet_gateway" "ubuntu_web_igw" {
  vpc_id = aws_vpc.ubuntu_web_vpc.id

  tags = {
    Name  = "ubuntu-web-igw"
    Stack = "network"
  }
}

# ─── Route table ─────────────────────────────────────────────────────────────

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

resource "aws_route_table_association" "ubuntu_web_rtb_assoc" {
  subnet_id      = aws_subnet.ubuntu_web_subnet_public.id
  route_table_id = aws_route_table.ubuntu_web_rtb_public.id
}

# ─── Security group ──────────────────────────────────────────────────────────

resource "aws_security_group" "ubuntu_web_sg" {
  name        = "ubuntu-web-sg"
  description = "Allow HTTP (80) and SSH (22) inbound; all outbound"
  vpc_id      = aws_vpc.ubuntu_web_vpc.id

  tags = {
    Name  = "ubuntu-web-sg"
    Stack = "network"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ubuntu_web_sg_http" {
  security_group_id = aws_security_group.ubuntu_web_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  description       = "Allow HTTP from anywhere"

  tags = {
    Name  = "ubuntu-web-sg-http"
    Stack = "network"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ubuntu_web_sg_ssh" {
  security_group_id = aws_security_group.ubuntu_web_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  description       = "Allow SSH from anywhere"

  tags = {
    Name  = "ubuntu-web-sg-ssh"
    Stack = "network"
  }
}

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

# ─── EC2 instance ────────────────────────────────────────────────────────────

resource "aws_instance" "ubuntu_web_server" {
  ami                    = data.aws_ami.ubuntu_22_04.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.ubuntu_web_subnet_public.id
  vpc_security_group_ids = [aws_security_group.ubuntu_web_sg.id]
  key_name               = data.aws_key_pair.ubuntu_web_key.key_name

  depends_on = [aws_internet_gateway.ubuntu_web_igw]

  tags = {
    Name  = "ubuntu-web-server"
    Stack = "network"
  }
}

# ─── Elastic IP ──────────────────────────────────────────────────────────────

resource "aws_eip" "ubuntu_web_eip" {
  domain   = "vpc"
  instance = aws_instance.ubuntu_web_server.id

  depends_on = [aws_internet_gateway.ubuntu_web_igw]

  tags = {
    Name  = "ubuntu-web-eip"
    Stack = "network"
  }
}

# ─── Outputs ─────────────────────────────────────────────────────────────────

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.ubuntu_web_vpc.id
}

output "subnet_public_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.ubuntu_web_subnet_public.id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.ubuntu_web_igw.id
}

output "security_group_id" {
  description = "ID of the web security group"
  value       = aws_security_group.ubuntu_web_sg.id
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.ubuntu_web_server.id
}

output "elastic_ip" {
  description = "Static public Elastic IP address assigned to the instance"
  value       = aws_eip.ubuntu_web_eip.public_ip
}

output "ssh_command" {
  description = "SSH command to connect to the instance (requires ubuntu-web-key.pem)"
  value       = "ssh -i ubuntu-web-key.pem ubuntu@${aws_eip.ubuntu_web_eip.public_ip}"
}