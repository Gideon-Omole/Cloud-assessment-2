# DynamoDB table for state locking
resource "aws_dynamodb_table" "tf_lock" {
  name         = aws_s3_bucket.tf_state.bucket
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}