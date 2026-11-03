resource "aws_s3_bucket" "bucket" {
  bucket        = "bk-2873656128790"
  force_destroy = true

  tags = {
    Name  = "bk-2873656128790"
    Stack = "s3-bucket"
  }
}