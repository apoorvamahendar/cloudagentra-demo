resource "aws_s3_bucket" "bucket_v3" {
  bucket = "bk-2878901283-v3"
}

resource "aws_s3_bucket_ownership_controls" "bucket_v3" {
  bucket = aws_s3_bucket.bucket_v3.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "bucket_v3" {
  bucket                  = aws_s3_bucket.bucket_v3.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_v3" {
  bucket = aws_s3_bucket.bucket_v3.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

output "remaining_bucket_id" {
  value = aws_s3_bucket.bucket_v3.id
}