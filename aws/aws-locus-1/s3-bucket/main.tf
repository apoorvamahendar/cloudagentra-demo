resource "aws_s3_bucket" "cloudagentra_storage_bucket_77655" {
  bucket        = "cloudagentra-storage-bucket-77655"
  force_destroy = true

  tags = {
    Name  = "cloudagentra-storage-bucket-77655"
    Stack = "s3-bucket"
  }
}

resource "aws_s3_bucket_versioning" "cloudagentra_storage_bucket_77655_versioning" {
  bucket = aws_s3_bucket.cloudagentra_storage_bucket_77655.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "cloudagentra_storage_bucket_77655_public_access_block" {
  bucket = aws_s3_bucket.cloudagentra_storage_bucket_77655.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "cloudagentra_storage_bucket_77655_ownership_controls" {
  bucket = aws_s3_bucket.cloudagentra_storage_bucket_77655.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }

  depends_on = [aws_s3_bucket_public_access_block.cloudagentra_storage_bucket_77655_public_access_block]
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudagentra_storage_bucket_77655_sse" {
  bucket = aws_s3_bucket.cloudagentra_storage_bucket_77655.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

output "bucket_id" {
  description = "The name (ID) of the S3 bucket."
  value       = aws_s3_bucket.cloudagentra_storage_bucket_77655.id
}

output "bucket_arn" {
  description = "The ARN of the S3 bucket."
  value       = aws_s3_bucket.cloudagentra_storage_bucket_77655.arn
}

output "bucket_region" {
  description = "The AWS region the bucket was created in."
  value       = aws_s3_bucket.cloudagentra_storage_bucket_77655.region
}