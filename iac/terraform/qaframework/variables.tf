variable "bucket_name" {
  type        = string
  description = "enter the bucket name"
}
variable "default_args" {
  type = map(string)
}

variable "team-name" {
}
variable "env" {
}
locals {
  name = "${var.team-name}-${var.env}"
}
