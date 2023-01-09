provider "aws" {
  region = "us-east-2"
}

variable "bucket_name" {
  type        = string
  description = "enter the bucket name"
}
## s3 bucket creation module

module "s3bucket" {
  source      = "../modules/s3bucket"
  bucket_name = var.bucket_name
}

output "s3-bucketname" {
  value = module.s3bucket.s3-bucketname
}

module "glue" {
  source            = "../modules/glue-spark"
  glue_s3_bucket    = module.s3bucket.s3-bucketname
  glue_script_s3key = "scripts/glue-compress.py"
  glue_script_path  = "../../../qaframework/scripts/glue-compress.py"

  glue_job_name = "my glue job jenkins"
  # role_arn = 

  depends_on = [
    module.s3bucket,
    module.s3-dir-upload
  ]
}

module "s3-dir-upload" {
  source      = "../modules/s3-directory-upload"
  dir-path    = "../../../qaframework"
  bucket_name = module.s3bucket.s3-bucketname
}


output "glue-job-name" {
  value = module.glue.glue-job-name
}

output "glue-arn" {
  value = module.glue.glue-job-arn

}

output "glue-job-id" {
  value = module.glue.glue-job-id
}