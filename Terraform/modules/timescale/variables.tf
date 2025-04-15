variable "ts_project_id" {
  default = "fvepwqywe3"
}

variable "ts_access_key" {
  default = "01JJCMX2DDK1BD51KWNP58C6W8"
}

variable "ts_secret_key" {
  description = "Enter the Timescale secret key"
  type        = string
  sensitive   = true
}