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

# ---------------------------------------------------------------------------
# Persist private key to disk as web-server-key.pem (mode 0400)
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Upload public key to AWS
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# EC2 instance - t2.micro, Ubuntu 22.04 LTS, public subnet
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Elastic IP - associate with the web server instance
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------

output "web_server_ami_id" {
  description = "AMI ID resolved for Ubuntu 22.04 LTS"
  value       = data.aws_ami.ubuntu_2204.id
}
