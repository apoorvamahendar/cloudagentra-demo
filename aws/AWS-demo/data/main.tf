resource "aws_dynamodb_table" "todos_table" {
  name         = "cloudagentra-demo-todos"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name  = "cloudagentra-demo-todos"
    Stack = "data"
    App   = "cloudagentra-demo"
  }
}