# ---------------------------------------------------------------------------
# Data sources - look up already-deployed network resources by name
# ---------------------------------------------------------------------------

data "aws_vpc" "web_server_vpc" {
  tags = {
    Name = "web-server-vpc"
  }
}

data "aws_subnet" "web_server_public_subnet" {
  tags = {
    Name = "web-server-public-subnet"
  }
}

data "aws_security_group" "web_server_sg" {
  name   = "web-server-sg"
  vpc_id = data.aws_vpc.web_server_vpc.id
}

# ---------------------------------------------------------------------------
# Resolve latest Ubuntu 22.04 LTS AMI from Canonical
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
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# ---------------------------------------------------------------------------
# TLS key pair - generate RSA-4096 private key
# ---------------------------------------------------------------------------

resource "tls_private_key" "web_server_tls_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# ---------------------------------------------------------------------------
# Persist private key to disk as web-server-key.pem (mode 0400)
# ---------------------------------------------------------------------------

resource "local_sensitive_file" "web_server_pem" {
  content         = tls_private_key.web_server_tls_key.private_key_pem
  filename        = "${path.module}/web-server-key.pem"
  file_permission = "0400"
}

# ---------------------------------------------------------------------------
# Upload public key to AWS
# ---------------------------------------------------------------------------

resource "aws_key_pair" "web_server_key" {
  key_name   = "web-server-key"
  public_key = tls_private_key.web_server_tls_key.public_key_openssh

  tags = {
    Name  = "web-server-key"
    Stack = "compute"
  }
}

# ---------------------------------------------------------------------------
# EC2 instance - t2.micro, Ubuntu 22.04 LTS, public subnet
# ---------------------------------------------------------------------------

resource "aws_instance" "web_server_instance" {
  ami                    = data.aws_ami.ubuntu_2204.id
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
    Name  = "web-server"
    Stack = "compute"
  }
}

# ---------------------------------------------------------------------------
# Elastic IP - associate with the web server instance
# ---------------------------------------------------------------------------

resource "aws_eip" "web_server_eip" {
  instance = aws_instance.web_server_instance.id
  domain   = "vpc"

  tags = {
    Name  = "web-server-eip"
    Stack = "compute"
  }
}

# ---------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------

output "web_server_public_ip" {
  description = "Public IP address of the web server (via Elastic IP)"
  value       = aws_eip.web_server_eip.public_ip
}

output "web_server_ssh_command" {
  description = "SSH command to connect to the web server"
  value       = "ssh -i web-server-key.pem ubuntu@${aws_eip.web_server_eip.public_ip}"
}

output "web_server_instance_id" {
  description = "EC2 instance ID of the web server"
  value       = aws_instance.web_server_instance.id
}

output "web_server_key_pair_name" {
  description = "Name of the AWS key pair used for SSH access"
  value       = aws_key_pair.web_server_key.key_name
}

output "web_server_ami_id" {
  description = "AMI ID resolved for Ubuntu 22.04 LTS"
  value       = data.aws_ami.ubuntu_2204.id
}
