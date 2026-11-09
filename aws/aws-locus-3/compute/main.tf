# ── RSA key material ────────────────────────────────────────────────────────
resource "tls_private_key" "ubuntu_web_key_material" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# ── Write the private key to disk for platform .pem hand-off ────────────────
resource "local_sensitive_file" "ubuntu_web_key_pem" {
  content         = tls_private_key.ubuntu_web_key_material.private_key_pem
  filename        = "${path.module}/ubuntu-web-key.pem"
  file_permission = "0400"
}

# ── Register the public key with AWS ────────────────────────────────────────
resource "aws_key_pair" "ubuntu_web_key" {
  key_name   = "ubuntu-web-key"
  public_key = tls_private_key.ubuntu_web_key_material.public_key_openssh

  tags = {
    Name  = "ubuntu-web-key"
    Stack = "compute"
  }
}
