resource "aws_s3_bucket" "bk_prod_logs_8040" {
  bucket        = "bk-prod-logs-8040"
  force_destroy = false

  tags = {
    Name       = "bk-prod-logs-8040"
    Stack      = "s3-bucket"
    ManagedBy  = "opentofu"
  }
}

resource "aws_s3_bucket_public_access_block" "bk_prod_logs_8040_public_access_block" {
  bucket = aws_s3_bucket.bk_prod_logs_8040.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bk_prod_logs_8040_sse" {
  bucket = aws_s3_bucket.bk_prod_logs_8040.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "bk_prod_logs_8040_versioning" {
  bucket = aws_s3_bucket.bk_prod_logs_8040.id

  versioning_configuration {
    status = "Disabled"
  }
}