# ─── TLS provider required for key generation ───────────────────────────────
# ─── Data sources - look up network resources already deployed by the network stack ───

data "aws_subnet" "vpc111_public_subnet_1" {
  filter {
    name   = "tag:Name"
    values = ["web-server-public-subnet"]
  }
}

data "aws_security_group" "vpc111_sg" {
  name = "web-server-sg"
}

# ─── Resolve latest Ubuntu 22.04 LTS AMI in ap-south-1 ──────────────────────

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

# ─── Generate RSA 4096-bit private key ──────────────────────────────────────

resource "tls_private_key" "vpc111_tls_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# ─── Register public key with AWS ───────────────────────────────────────────

resource "aws_key_pair" "vpc111_key" {
  key_name   = "vpc111-key"
  public_key = tls_private_key.vpc111_tls_key.public_key_openssh

  tags = {
    Name  = "vpc111-key"
    Stack = "compute"
  }
}

# ─── Write private key to vpc111-key.pem locally (chmod 400) ────────────────

resource "local_sensitive_file" "vpc111_pem" {
  content         = tls_private_key.vpc111_tls_key.private_key_pem
  filename        = "${path.module}/vpc111-key.pem"
  file_permission = "0400"
}

# ─── EC2 instance - Ubuntu 22.04 LTS, t2.micro, public subnet ───────────────

resource "aws_instance" "vpc111_ec2" {
  ami                         = data.aws_ami.ubuntu_22_04.id
  instance_type               = "t2.micro"
  subnet_id                   = data.aws_subnet.vpc111_public_subnet_1.id
  vpc_security_group_ids      = [data.aws_security_group.vpc111_sg.id]
  key_name                    = aws_key_pair.vpc111_key.key_name
  associate_public_ip_address = true

  tags = {
    Name  = "vpc111-ec2"
    Stack = "compute"
  }

  depends_on = [aws_key_pair.vpc111_key]
}
