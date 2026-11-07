# ─────────────────────────────────────────────────────────────────────────────
# Data sources - reference resources owned by other stacks
# ─────────────────────────────────────────────────────────────────────────────

data "aws_vpc" "web_server" {
  filter {
    name   = "tag:Name"
    values = ["web-server-vpc"]
  }

  filter {
    name   = "cidr"
    values = ["10.0.0.0/16"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

data "aws_internet_gateway" "web_server" {
  filter {
    name   = "attachment.vpc-id"
    values = [data.aws_vpc.web_server.id]
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# Public subnet
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_subnet" "public" {
  vpc_id                  = data.aws_vpc.web_server.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name  = "web-server-subnet-public"
    Stack = "network"
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# Public route table - routes all egress to the Internet Gateway
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_route_table" "public" {
  vpc_id = data.aws_vpc.web_server.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.aws_internet_gateway.web_server.id
  }

  tags = {
    Name  = "web-server-rtb-public"
    Stack = "network"
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# Associate the public route table with the public subnet
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# ─────────────────────────────────────────────────────────────────────────────
# S3 bucket - private, encrypted, versioning disabled
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_s3_bucket" "bk_123617919" {
  bucket        = "bk-123617919"
  force_destroy = true

  tags = {
    Name  = "bk-123617919"
    Stack = "network"
  }
}

resource "aws_s3_bucket_public_access_block" "bk_123617919_public_access_block" {
  bucket = aws_s3_bucket.bk_123617919.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bk_123617919_sse" {
  bucket = aws_s3_bucket.bk_123617919.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}