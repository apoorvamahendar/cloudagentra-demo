# ─────────────────────────────────────────────────────────────────────────────
# EXISTING RESOURCES - preserved exactly as deployed
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name  = "my-app-vpc"
    Stack = "network"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name  = "my-app-subnet-public"
    Stack = "network"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name  = "my-app-igw"
    Stack = "network"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name  = "my-app-public-rt"
    Stack = "network"
  }
}

resource "aws_route_table_association" "public_rt_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "web_ssh_sg" {
  name        = "my-app-web-ssh-sg"
  description = "Allow inbound HTTP (80) and SSH (22) from anywhere"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
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
    Name  = "my-app-web-ssh-sg"
    Stack = "network"
  }
}

resource "aws_s3_bucket" "bk_123617919" {
  bucket        = "bk-123617919"
  force_destroy = true

  tags = {
    Name  = "bk-123617919"
    Stack = "network"
  }
}

resource "aws_s3_bucket_public_access_block" "bk_123617919_public_access_block" {
  bucket = aws_s3_bucket.bk_123617919.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bk_123617919_sse" {
  bucket = aws_s3_bucket.bk_123617919.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

data "aws_vpc" "web_server" {
  filter {
    name   = "tag:Name"
    values = ["web-server-vpc"]
  }

  filter {
    name   = "cidr"
    values = ["10.0.0.0/16"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

data "aws_internet_gateway" "web_server" {
  filter {
    name   = "attachment.vpc-id"
    values = [data.aws_vpc.web_server.id]
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = data.aws_vpc.web_server.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name  = "web-server-subnet-public"
    Stack = "network"
  }
}

resource "aws_route_table" "public" {
  vpc_id = data.aws_vpc.web_server.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.aws_internet_gateway.web_server.id
  }

  tags = {
    Name  = "web-server-rtb-public"
    Stack = "network"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# ─────────────────────────────────────────────────────────────────────────────
# NEW RESOURCES - ubuntu-web networking stack
# ─────────────────────────────────────────────────────────────────────────────

# VPC: ubuntu-web-vpc
resource "aws_vpc" "ubuntu_web_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name  = "ubuntu-web-vpc"
    Stack = "network"
  }
}

# Public Subnet: ubuntu-web-subnet-public
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

# Internet Gateway: ubuntu-web-igw
resource "aws_internet_gateway" "ubuntu_web_igw" {
  vpc_id = aws_vpc.ubuntu_web_vpc.id

  tags = {
    Name  = "ubuntu-web-igw"
    Stack = "network"
  }
}

# Route Table: ubuntu-web-rtb-public - default route via IGW
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

# Route Table Association: ubuntu-web-rtb-public → ubuntu-web-subnet-public
resource "aws_route_table_association" "ubuntu_web_rtb_assoc" {
  subnet_id      = aws_subnet.ubuntu_web_subnet_public.id
  route_table_id = aws_route_table.ubuntu_web_rtb_public.id
}

# Security Group: ubuntu-web-sg - HTTP (80) and SSH (22) inbound; all outbound
resource "aws_security_group" "ubuntu_web_sg" {
  name        = "ubuntu-web-sg"
  description = "Allow inbound HTTP (80) and SSH (22) from anywhere; all outbound"
  vpc_id      = aws_vpc.ubuntu_web_vpc.id

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
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "ubuntu-web-sg"
    Stack = "network"
  }
}