# ── Archive provider declaration (needed alongside hashicorp/aws) ────────────
# ── Package backend/handler.py into a zip for Lambda ─────────────────────────
data "archive_file" "todo_backend_zip" {
  type        = "zip"
  source_file = "${path.module}/backend/handler.py"
  output_path = "${path.module}/backend_handler.zip"
}

# ── Lambda Function ───────────────────────────────────────────────────────────
resource "aws_lambda_function" "todo_backend" {
  function_name    = "cloudagentra-demo-todo-backend"
  filename         = data.archive_file.todo_backend_zip.output_path
  source_code_hash = data.archive_file.todo_backend_zip.output_base64sha256
  handler          = "handler.lambda_handler"
  runtime          = "python3.12"
  role             = "arn:aws:iam::444062204915:role/cloudagentra-demo-todo-lambda-role"
  timeout          = 30
  memory_size      = 128

  environment {
    variables = {
      TODOS_TABLE = "cloudagentra-demo-todos"
    }
  }

  tags = {
    Project = "cloudagentra-demo"
    Stack   = "todo-app"
  }
}

# ── HTTP API Gateway (v2) ─────────────────────────────────────────────────────
resource "aws_apigatewayv2_api" "todo_api" {
  name          = "cloudagentra-demo-todo-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["*"]
    allow_headers = ["*"]
  }

  tags = {
    Project = "cloudagentra-demo"
    Stack   = "todo-app"
  }
}

# ── Lambda proxy integration ──────────────────────────────────────────────────
resource "aws_apigatewayv2_integration" "todo_lambda_integration" {
  api_id                 = aws_apigatewayv2_api.todo_api.id
  integration_type       = "AWS_PROXY"
  integration_method     = "POST"
  integration_uri        = aws_lambda_function.todo_backend.invoke_arn
  payload_format_version = "2.0"
}

# ── Catch-all route ───────────────────────────────────────────────────────────
resource "aws_apigatewayv2_route" "todo_catch_all_route" {
  api_id    = aws_apigatewayv2_api.todo_api.id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.todo_lambda_integration.id}"
}

# ── $default stage with auto-deploy ──────────────────────────────────────────
resource "aws_apigatewayv2_stage" "todo_default_stage" {
  api_id      = aws_apigatewayv2_api.todo_api.id
  name        = "$default"
  auto_deploy = true

  tags = {
    Project = "cloudagentra-demo"
    Stack   = "todo-app"
  }

  depends_on = [aws_apigatewayv2_route.todo_catch_all_route]
}

# ── Grant API Gateway permission to invoke Lambda ─────────────────────────────
resource "aws_lambda_permission" "todo_apigw_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.todo_backend.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.todo_api.execution_arn}/*/*"
}

# ── Upload patched index.html to the existing S3 static-site bucket ───────────
# __API_URL__ in the HTML is replaced at apply time with the live invoke URL.
resource "aws_s3_object" "frontend_index" {
  bucket       = "cloudagentra-demo-todo-frontend"
  key          = "index.html"
  content_type = "text/html"

  content = replace(
    file("${path.module}/frontend/index.html"),
    "__API_URL__",
    aws_apigatewayv2_stage.todo_default_stage.invoke_url
  )

  etag = md5(replace(
    file("${path.module}/frontend/index.html"),
    "__API_URL__",
    aws_apigatewayv2_stage.todo_default_stage.invoke_url
  ))

  tags = {
    Project = "cloudagentra-demo"
    Stack   = "todo-app"
  }

  depends_on = [aws_apigatewayv2_stage.todo_default_stage]
}

# ── Outputs ───────────────────────────────────────────────────────────────────
resource "aws_iam_role" "todo_lambda_role" {
  name = "cloudagentra-demo-todo-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    stack   = "iam"
    project = "cloudagentra-demo"
  }
}

resource "aws_iam_role_policy" "todo_lambda_policy" {
  name = "cloudagentra-demo-todo-lambda-policy"
  role = aws_iam_role.todo_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Scan",
          "dynamodb:Query"
        ]
        Resource = "arn:aws:dynamodb:ap-south-1:444062204915:table/cloudagentra-demo-todos"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}
