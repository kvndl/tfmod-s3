variable "bucket_name" {}

variable "whitelist" {
  type    = list(string)
  default = []
}