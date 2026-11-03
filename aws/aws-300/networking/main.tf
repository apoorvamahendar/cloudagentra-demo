data "aws_instance" "ec2_public_instance" {
  filter {
    name   = "tag:Name"
    values = ["ec2-public-instance"]
  }

  filter {
    name   = "instance-state-name"
    values = ["running", "stopped", "pending"]
  }
}

data "aws_internet_gateway" "ec2_public_igw" {
  filter {
    name   = "tag:Name"
    values = ["ec2-public-igw"]
  }
}

resource "aws_eip" "ec2_public_eip" {
  instance = data.aws_instance.ec2_public_instance.id
  domain   = "vpc"

  depends_on = [data.aws_internet_gateway.ec2_public_igw]

  tags = {
    Name  = "ec2-public-eip"
    Stack = "networking"
  }
}