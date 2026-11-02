resource "aws_s3_bucket" "bk_287653789" {
  bucket        = "bk-287653789"
  force_destroy = true

  tags = {
    Name  = "bk-287653789"
    Stack = "s3-bucket"
  }
}

resource "aws_s3_bucket_acl" "bk_287653789_acl" {
  depends_on = [aws_s3_bucket.bk_287653789]

  bucket = aws_s3_bucket.bk_287653789.id
  acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bk_287653789_sse" {
  bucket = aws_s3_bucket.bk_287653789.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "bk_287653789_public_access_block" {
  bucket                  = aws_s3_bucket.bk_287653789.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}