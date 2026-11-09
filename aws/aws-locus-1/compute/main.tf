# ---------------------------------------------------------------------------
# Data sources - look up resources already deployed by the 'network' stack
# ---------------------------------------------------------------------------

data "aws_subnet" "web_server_public_subnet" {
  filter {
    name   = "tag:Name"
    values = ["web-server-public-subnet"]
  }
}

data "aws_security_group" "web_server_sg" {
  filter {
    name   = "group-name"
    values = ["web-server-sg"]
  }
}

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
    name   = "architecture"
    values = ["x86_64"]
  }
}

# ---------------------------------------------------------------------------
# TLS key pair - 4096-bit RSA, generated locally
# ---------------------------------------------------------------------------

resource "tls_private_key" "web_server_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# ---------------------------------------------------------------------------
# AWS key pair - register public key with AWS
# ---------------------------------------------------------------------------

resource "aws_key_pair" "web_server_kp" {
  key_name   = "web-server-keypair"
  public_key = tls_private_key.web_server_key.public_key_openssh

  tags = {
    Name  = "web-server-keypair"
    Stack = "compute"
  }
}

# ---------------------------------------------------------------------------
# Local .pem file - write private key for SSH access
# ---------------------------------------------------------------------------

resource "local_file" "web_server_pem" {
  content         = tls_private_key.web_server_key.private_key_pem
  filename        = "web-server-key.pem"
  file_permission = "0400"
}

# ---------------------------------------------------------------------------
# EC2 instance - Ubuntu 22.04 LTS, t2.micro, public subnet
# ---------------------------------------------------------------------------

resource "aws_instance" "web_server" {
  ami                    = data.aws_ami.ubuntu_22_04.id
  instance_type          = "t2.micro"
  subnet_id              = data.aws_subnet.web_server_public_subnet.id
  vpc_security_group_ids = [data.aws_security_group.web_server_sg.id]
  key_name               = aws_key_pair.web_server_kp.key_name
  associate_public_ip_address = true

  tags = {
    Name  = "web-server-ec2"
    Stack = "compute"
  }
}