terraform {
  backend "s3" {
    bucket  = "secops-reptool-state"
    key     = "terraform.tfstate"
    region  = "eu-west-2"
    encrypt = true
  }
}
