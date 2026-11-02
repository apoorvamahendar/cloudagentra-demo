output "todo_lambda_role_arn" {
  description = "ARN of the Lambda execution role for the todo backend."
  value       = aws_iam_role.todo_lambda_role.arn
}

output "todo_lambda_role_name" {
  description = "Name of the Lambda execution role for the todo backend."
  value       = aws_iam_role.todo_lambda_role.name
}

output "todo_lambda_policy_id" {
  description = "ID of the inline IAM policy attached to the Lambda execution role."
  value       = aws_iam_role_policy.todo_lambda_policy.id
}