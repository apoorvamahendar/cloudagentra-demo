resource "aws_s3_bucket" "v3_bucket" {
  bucket = "bk-2878901283-v3"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "v3_bucket_encryption" {
  bucket = aws_s3_bucket.v3_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "v3_bucket_access_block" {
  bucket                  = aws_s3_bucket.v3_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "v3_bucket_ownership" {
  bucket = aws_s3_bucket.v3_bucket.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket" "bucket" {
  bucket        = "bk-2873656128790"
  force_destroy = true

  tags = {
    Name  = "bk-2873656128790"
    Stack = "s3-bucket"
  }
}
