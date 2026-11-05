output "prod_logs_62738929_bucket_id" {
  description = "The name/ID of the prod-logs-62738929 S3 bucket."
  value       = aws_s3_bucket.prod_logs_62738929.id
}

output "prod_logs_62738929_bucket_arn" {
  description = "The ARN of the prod-logs-62738929 S3 bucket."
  value       = aws_s3_bucket.prod_logs_62738929.arn
}