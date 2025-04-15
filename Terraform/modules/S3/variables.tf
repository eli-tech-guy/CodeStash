variable "s3_buckets" {
  type    = list(string)
  default = [
    "dremio-s3-kafka-write",
    "dremio-s3-projectstore",
    "onehouse-s3-load",
    "onehouse-s3-scripts",
    "onehouse-s3-tables"
  ]
}