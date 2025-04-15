terraform {
  backend "s3" {
    bucket         = "terraform-speedcast-state" # Use the same bucket name as defined above
    key            = "terraform/state.tfstate"
    region         = "us-east-1"                # Replace with your region
    dynamodb_table = "terraform-locks"          # Use the same DynamoDB table name as defined above
    encrypt        = true
  }
}
