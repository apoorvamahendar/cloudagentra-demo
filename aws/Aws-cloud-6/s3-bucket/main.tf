resource "aws_s3_bucket" "prod_logs_27738" {
  bucket        = "prod-logs-27738"
  force_destroy = true

  tags = {
    Name  = "prod-logs-27738"
    Stack = "s3-bucket"
  }
}

resource "aws_s3_bucket_public_access_block" "prod_logs_27738_public_access_block" {
  bucket = aws_s3_bucket.prod_logs_27738.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "prod_logs_27738_ownership_controls" {
  bucket = aws_s3_bucket.prod_logs_27738.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }

  depends_on = [aws_s3_bucket_public_access_block.prod_logs_27738_public_access_block]
}

resource "aws_s3_bucket_server_side_encryption_configuration" "prod_logs_27738_sse" {
  bucket = aws_s3_bucket.prod_logs_27738.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "prod_logs_27738_versioning" {
  bucket = aws_s3_bucket.prod_logs_27738.id

  versioning_configuration {
    status = "Disabled"
  }
}