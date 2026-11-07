output "subnet_public_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public.id
}

output "route_table_public_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public.id
}

output "bk_123617919_id" {
  description = "ID (name) of the S3 bucket bk-123617919"
  value       = aws_s3_bucket.bk_123617919.id
}

output "bk_123617919_arn" {
  description = "ARN of the S3 bucket bk-123617919"
  value       = aws_s3_bucket.bk_123617919.arn
}