# ── Extra providers (tls + local) ─────────────────────────────────────────────
# The host's provider.tf already declares the aws provider and var.aws_region.
# We only add the two utility providers this stack needs.
# ── Ubuntu 22.04 LTS AMI (ap-south-1) ─────────────────────────────────────────
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

# ── Cross-stack references: look up networking resources by name ───────────────
data "aws_subnet" "web_server_public_subnet" {
  filter {
    name   = "tag:Name"
    values = ["web-server-public-subnet"]
  }
}

data "aws_security_group" "web_server_sg" {
  filter {
    name   = "tag:Name"
    values = ["web-server-sg"]
  }
}

# ── TLS private key (RSA 4096) ─────────────────────────────────────────────────
resource "tls_private_key" "web_server_tls_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# ── Write private key to disk so the platform can surface it for download ──────
resource "local_file" "web_server_key_pem" {
  content         = tls_private_key.web_server_tls_key.private_key_pem
  filename        = "${path.module}/web-server-key.pem"
  file_permission = "0600"
}

# ── AWS Key Pair (upload public key to EC2) ────────────────────────────────────
resource "aws_key_pair" "web_server_key" {
  key_name   = "web-server-key"
  public_key = tls_private_key.web_server_tls_key.public_key_openssh

  tags = {
    Name  = "web-server-key"
    Stack = "compute"
  }
}

# ── EC2 Instance ───────────────────────────────────────────────────────────────
resource "aws_instance" "web_server_instance" {
  ami                    = data.aws_ami.ubuntu_22_04.id
  instance_type          = "t2.micro"
  subnet_id              = data.aws_subnet.web_server_public_subnet.id
  vpc_security_group_ids = [data.aws_security_group.web_server_sg.id]
  key_name               = aws_key_pair.web_server_key.key_name

  root_block_device {
    volume_size           = 8
    volume_type           = "gp2"
    delete_on_termination = true
  }

  tags = {
    Name  = "web-server-instance"
    Stack = "compute"
  }
}
