provider "aws" {
  region  = "us-east-1"
}


locals {
  workspace_suffix = terraform.workspace == "staging" ? "-stg" : ""
}

resource "aws_s3_bucket" "poc_buckets" {
  for_each = toset(var.s3_buckets)

  bucket = "${each.value}${local.workspace_suffix}"

  tags = {
    Name        = "${each.value}${local.workspace_suffix}"
    Environment = "ingest"
  }
}
