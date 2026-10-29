output "dynamodb_table_name" {
  description = "Name of the DynamoDB table for Todo items"
  value       = aws_dynamodb_table.todo_table.name
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table for Todo items"
  value       = aws_dynamodb_table.todo_table.arn
}