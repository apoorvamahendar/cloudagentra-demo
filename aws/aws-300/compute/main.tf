# ---------------------------------------------------------------------------
# Data sources - look up resources already deployed by the 'network' stack
# ---------------------------------------------------------------------------

data "aws_subnet" "ec2_public_subnet" {
  filter {
    name   = "tag:Name"
    values = ["ec2-public-subnet"]
  }
}

data "aws_security_group" "ec2_public_sg" {
  filter {
    name   = "group-name"
    values = ["ec2-public-sg"]
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
# TLS key pair
# ---------------------------------------------------------------------------

resource "tls_private_key" "ec2_tls_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_sensitive_file" "ec2_private_key_pem" {
  content         = tls_private_key.ec2_tls_key.private_key_pem
  filename        = "ec2-key-pair.pem"
  file_permission = "0600"
}

resource "aws_key_pair" "ec2_key_pair" {
  key_name   = "ec2-key-pair"
  public_key = tls_private_key.ec2_tls_key.public_key_openssh

  tags = {
    Name  = "ec2-key-pair"
    Stack = "compute"
  }
}

# ---------------------------------------------------------------------------
# EC2 instance
# ---------------------------------------------------------------------------

resource "aws_instance" "ec2_public_instance" {
  ami                    = data.aws_ami.ubuntu_22_04.id
  instance_type          = "t2.micro"
  subnet_id              = data.aws_subnet.ec2_public_subnet.id
  vpc_security_group_ids = [data.aws_security_group.ec2_public_sg.id]
  key_name               = aws_key_pair.ec2_key_pair.key_name

  tags = {
    Name  = "ec2-public-instance"
    Stack = "compute"
  }
}