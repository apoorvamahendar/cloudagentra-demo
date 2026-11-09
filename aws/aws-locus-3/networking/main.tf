# Look up the EIP deployed by the 'network' stack (tagged Name = "ubuntu-web-eip")
data "aws_eip" "ubuntu_web_eip" {
  tags = {
    Name = "ubuntu-web-eip"
  }
}

# Look up the EC2 instance deployed by the 'network' stack (tagged Name = "ubuntu-web-server")
data "aws_instance" "ubuntu_web_server" {
  filter {
    name   = "tag:Name"
    values = ["ubuntu-web-server"]
  }

  filter {
    name   = "instance-state-name"
    values = ["running", "pending"]
  }
}

# Associate the Elastic IP with the EC2 instance
resource "aws_eip_association" "ubuntu_web_eip_assoc" {
  allocation_id = data.aws_eip.ubuntu_web_eip.id
  instance_id   = data.aws_instance.ubuntu_web_server.id
}