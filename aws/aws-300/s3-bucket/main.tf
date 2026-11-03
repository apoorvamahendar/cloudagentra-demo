resource "aws_s3_bucket" "cloudagentra_storage_bucket" {
  bucket = "cloudagentra-storage-bucket-287563e"
}

resource "aws_s3_bucket_versioning" "cloudagentra_storage_versioning" {
  bucket = aws_s3_bucket.cloudagentra_storage_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "cloudagentra_storage_public_block" {
  bucket                  = aws_s3_bucket.cloudagentra_storage_bucket.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "second_bucket" {
  bucket = "bucket-298973654092390992"
}

resource "aws_s3_bucket_versioning" "second_versioning" {
  bucket = aws_s3_bucket.second_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "second_public_block" {
  bucket                  = aws_s3_bucket.second_bucket.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}