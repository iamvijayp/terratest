variable "dir-path" {
  type = string
}
variable "dir-name" {
  type=string
  default = "qaframework"
}
variable "bucket_name" {
  type = string
  #default = "aws-glue-job-test-vijay-jenkins"
}


resource "aws_s3_object" "dist" {
  bucket = var.bucket_name
  for_each = fileset(var.dir-path, "**")
  #key    = "${var.dir-name}/${each.value}"
  key    = each.value
  source = "${var.dir-path}/${each.value}"
  etag = filemd5("${var.dir-path}/${each.value}")
}