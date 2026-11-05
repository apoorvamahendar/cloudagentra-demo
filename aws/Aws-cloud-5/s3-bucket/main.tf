resource "aws_s3_bucket" "bk_prod_logs7030" {
  bucket        = "bk-prod-logs7030"
  force_destroy = false

  tags = {
    Name       = "bk-prod-logs7030"
    stack      = "s3-bucket"
    managed-by = "opentofu"
  }
}

resource "aws_s3_bucket_public_access_block" "bk_prod_logs7030_public_access_block" {
  bucket = aws_s3_bucket.bk_prod_logs7030.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bk_prod_logs7030_sse" {
  bucket = aws_s3_bucket.bk_prod_logs7030.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "bk_prod_logs7030_versioning" {
  bucket = aws_s3_bucket.bk_prod_logs7030.id

  versioning_configuration {
    status = "Enabled"
  }
}