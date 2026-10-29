output "frontend_bucket_id" {
  description = "The name/ID of the S3 frontend bucket."
  value       = aws_s3_bucket.frontend_bucket.id
}

output "frontend_bucket_arn" {
  description = "The ARN of the S3 frontend bucket."
  value       = aws_s3_bucket.frontend_bucket.arn
}

output "frontend_bucket_website_endpoint" {
  description = "The S3 static website endpoint for the frontend bucket."
  value       = aws_s3_bucket_website_configuration.frontend_bucket_website.website_endpoint
}