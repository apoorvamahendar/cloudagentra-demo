resource "aws_s3_bucket" "static_site_bucket" {
  bucket        = "cloudagentra-statis-site52310982"
  force_destroy = true

  tags = {
    Name  = "cloudagentra-statis-site52310982"
    Stack = "storage"
  }
}

resource "aws_s3_bucket_public_access_block" "static_site_public_access_block" {
  bucket = aws_s3_bucket.static_site_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false

  depends_on = [aws_s3_bucket.static_site_bucket]
}

resource "aws_s3_bucket_website_configuration" "static_site_website_config" {
  bucket = aws_s3_bucket.static_site_bucket.id

  index_document {
    suffix = "index.html"
  }

  depends_on = [aws_s3_bucket_public_access_block.static_site_public_access_block]
}

resource "aws_s3_bucket_policy" "static_site_bucket_policy" {
  bucket = aws_s3_bucket.static_site_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.static_site_bucket.arn}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket_website_configuration.static_site_website_config]
}

output "static_site_bucket_id" {
  description = "The name (ID) of the S3 bucket."
  value       = aws_s3_bucket.static_site_bucket.id
}

output "static_site_bucket_arn" {
  description = "The ARN of the S3 static website bucket."
  value       = aws_s3_bucket.static_site_bucket.arn
}

output "static_site_website_endpoint" {
  description = "The public HTTP website endpoint for the S3 static site."
  value       = aws_s3_bucket_website_configuration.static_site_website_config.website_endpoint
}

output "static_site_website_url" {
  description = "Full public URL of the static website."
  value       = "http://${aws_s3_bucket_website_configuration.static_site_website_config.website_endpoint}"
}