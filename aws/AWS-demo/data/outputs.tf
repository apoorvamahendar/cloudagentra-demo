output "todos_table_name" {
  description = "Name of the DynamoDB todos table"
  value       = aws_dynamodb_table.todos_table.name
}

output "todos_table_arn" {
  description = "ARN of the DynamoDB todos table"
  value       = aws_dynamodb_table.todos_table.arn
}