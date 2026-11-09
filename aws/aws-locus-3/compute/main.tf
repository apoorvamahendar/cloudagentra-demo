# ─────────────────────────────────────────────────────────────────────────────
# Extra provider required: hashicorp/tls (key generation)
#                          hashicorp/local (write .pem to disk)
# ─────────────────────────────────────────────────────────────────────────────
# ─────────────────────────────────────────────────────────────────────────────
# Data sources - reference networking resources created by the networking stack
# ─────────────────────────────────────────────────────────────────────────────

data "aws_subnet" "main_public_subnet" {
  filter {
    name   = "tag:Name"
    values = ["main-public-subnet"]
  }
}

data "aws_security_group" "main_sg" {
  name = "main-sg"
}

# Latest Ubuntu 22.04 LTS AMI for ap-south-1 - resolved at deploy time
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

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# RSA-4096 key material
# ─────────────────────────────────────────────────────────────────────────────

resource "tls_private_key" "main_keypair_tls" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Write the private key to disk so the platform can surface it for download
resource "local_file" "main_keypair_pem" {
  content         = tls_private_key.main_keypair_tls.private_key_pem
  filename        = "${path.module}/main-keypair.pem"
  file_permission = "0600"
}

# ─────────────────────────────────────────────────────────────────────────────
# AWS Key Pair - registers the public half with EC2
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_key_pair" "main_keypair" {
  key_name   = "main-keypair"
  public_key = tls_private_key.main_keypair_tls.public_key_openssh

  tags = {
    Name  = "main-keypair"
    Stack = "compute"
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# EC2 Instance - t2.micro / Ubuntu 22.04 LTS in main-public-subnet
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_instance" "main_ec2" {
  ami                    = data.aws_ami.ubuntu_2204.id
  instance_type          = "t2.micro"
  subnet_id              = data.aws_subnet.main_public_subnet.id
  vpc_security_group_ids = [data.aws_security_group.main_sg.id]
  key_name               = aws_key_pair.main_keypair.key_name

  tags = {
    Name  = "main-ec2"
    Stack = "compute"
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# Outputs
# ─────────────────────────────────────────────────────────────────────────────

output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.main_ec2.id
}

output "instance_private_ip" {
  description = "Private IP address of main-ec2"
  value       = aws_instance.main_ec2.private_ip
}

output "key_pair_name" {
  description = "Name of the AWS key pair registered for main-ec2"
  value       = aws_key_pair.main_keypair.key_name
}

output "key_pair_pem_path" {
  description = "Local path where the private key PEM was written"
  value       = local_file.main_keypair_pem.filename
}

output "ami_id_resolved" {
  description = "Ubuntu 22.04 LTS AMI ID resolved at deploy time for ap-south-1"
  value       = data.aws_ami.ubuntu_2204.id
}
