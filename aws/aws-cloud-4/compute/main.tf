# ---------------------------------------------------------------------------
# TLS provider - required for tls_private_key
# (declared here because the host provider.tf only declares hashicorp/aws)
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Data sources - look up already-deployed network resources by their real
# tag:Name values as deployed by the 'network' stack
# ---------------------------------------------------------------------------

data "aws_subnet" "public_subnet" {
  filter {
    name   = "tag:Name"
    values = ["public-subnet"]
  }
}

data "aws_security_group" "web_ssh_sg" {
  name = "web-ssh-sg"
}

# ---------------------------------------------------------------------------
# Resolve the latest Ubuntu 22.04 LTS AMI in ap-south-1 (Canonical)
# ---------------------------------------------------------------------------

data "aws_ami" "ubuntu_2204" {
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
# TLS private key - RSA 2048-bit (as specified by the user)
# ---------------------------------------------------------------------------

resource "tls_private_key" "web_ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# ---------------------------------------------------------------------------
# AWS Key Pair - registers the TLS-generated public key with AWS
# ---------------------------------------------------------------------------

resource "aws_key_pair" "web_ec2_key_pair" {
  key_name   = "web-ec2-key-pair"
  public_key = tls_private_key.web_ec2_key.public_key_openssh

  tags = {
    Name  = "web-ec2-key-pair"
    Stack = "compute"
  }
}

# ---------------------------------------------------------------------------
# Write private key to disk (.pem) so the UI can surface it for download
# ---------------------------------------------------------------------------

resource "local_sensitive_file" "web_ec2_key_pem" {
  content         = tls_private_key.web_ec2_key.private_key_pem
  filename        = "${path.module}/web-ec2-key-pair.pem"
  file_permission = "0600"
}

# ---------------------------------------------------------------------------
# EC2 instance - t2.micro, Ubuntu 22.04 LTS, public subnet, 8 GB gp2 root
# ---------------------------------------------------------------------------

resource "aws_instance" "web_ec2_instance" {
  ami                    = data.aws_ami.ubuntu_2204.id
  instance_type          = "t2.micro"
  subnet_id              = data.aws_subnet.public_subnet.id
  vpc_security_group_ids = [data.aws_security_group.web_ssh_sg.id]
  key_name               = aws_key_pair.web_ec2_key_pair.key_name

  root_block_device {
    volume_size           = 8
    volume_type           = "gp2"
    delete_on_termination = true
  }

  tags = {
    Name  = "web-ec2-instance"
    Stack = "compute"
  }
}

resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ec2_key_pair" {
  key_name   = "vpc-234567898-keypair"
  public_key = tls_private_key.ec2_key.public_key_openssh

  tags = {
    Name  = "vpc-234567898-keypair"
    Stack = "compute"
  }
}

resource "local_sensitive_file" "private_key_file" {
  content         = tls_private_key.ec2_key.private_key_pem
  filename        = "${path.module}/ec2-private-key.pem"
  file_permission = "0600"
}

resource "aws_instance" "web_instance" {
  ami                    = data.aws_ami.ubuntu_2204.id
  instance_type          = "t2.micro"
  subnet_id              = data.aws_subnet.public_subnet.id
  vpc_security_group_ids = [data.aws_security_group.web_ssh_sg.id]
  key_name               = aws_key_pair.ec2_key_pair.key_name

  tags = {
    Name  = "vpc-234567898-ec2"
    Stack = "compute"
  }
}

# ---------------------------------------------------------------------------
# New plan resources: RSA 4096-bit key, AWS key pair, EC2 t2.micro instance
# with 20 GB gp3 root volume and Elastic IP
# ---------------------------------------------------------------------------

resource "tls_private_key" "web_ec2_key_new" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "web_ec2_key_pair_new" {
  key_name   = "web-ec2-key"
  public_key = tls_private_key.web_ec2_key_new.public_key_openssh

  tags = {
    Name  = "web-ec2-key"
    Stack = "compute"
  }
}

resource "local_sensitive_file" "web_ec2_key_new_pem" {
  content         = tls_private_key.web_ec2_key_new.private_key_pem
  filename        = "${path.module}/web-ec2-key.pem"
  file_permission = "0600"
}

resource "aws_instance" "web_ec2_instance_new" {
  ami                    = data.aws_ami.ubuntu_2204.id
  instance_type          = "t2.micro"
  subnet_id              = data.aws_subnet.public_subnet.id
  vpc_security_group_ids = [data.aws_security_group.web_ssh_sg.id]
  key_name               = aws_key_pair.web_ec2_key_pair_new.key_name

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name  = "web-ec2-instance-new"
    Stack = "compute"
  }
}

resource "aws_eip" "web_ec2_eip" {
  instance = aws_instance.web_ec2_instance_new.id
  domain   = "vpc"

  tags = {
    Name  = "web-ec2-eip"
    Stack = "compute"
  }
}