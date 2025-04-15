

resource "aws_s3_bucket" "secops-cdn-incoming" {
  bucket = "secops-cdn-incoming"
  acl    = "private"
}
