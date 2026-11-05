resource "aws_s3_bucket" "prod_logs" {
  bucket        = "bk-prod-logs-4090"
  force_destroy = false

  tags = {
    Name       = "bk-prod-logs-4090"
    Stack      = "s3-bucket"
    ManagedBy  = "opentofu"
    Region     = "ap-south-1"
  }
}

resource "aws_s3_bucket_public_access_block" "prod_logs_public_access_block" {
  bucket = aws_s3_bucket.prod_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "prod_logs_sse" {
  bucket = aws_s3_bucket.prod_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "prod_logs_versioning" {
  bucket = aws_s3_bucket.prod_logs.id

  versioning_configuration {
    status = "Disabled"
  }
}