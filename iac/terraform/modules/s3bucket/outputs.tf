output "s3-bucketname" {
    description = "name of s3 bucket"
  value= aws_s3_bucket.s3bucket.id
}