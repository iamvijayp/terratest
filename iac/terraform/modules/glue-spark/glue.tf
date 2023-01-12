resource "aws_s3_object" "upload_glue_script" {
  bucket = var.glue_s3_bucket
  key = var.glue_script_s3key
  source = var.glue_script_path
  etag = var.glue_script_path
}


resource "aws_glue_job" "glue-job" {
  name = var.glue_job_name
  role_arn = var.glue_arn
  description = "This is script to create large files from small files "
  max_retries = "1"
  timeout = 2880
  default_arguments = var.default_args

  command {
    script_location = "s3://${var.glue_s3_bucket}/${var.glue_script_s3key}"
    python_version = "3"
  }
  
  execution_property {
    max_concurrent_runs = 2
  }
  glue_version = "3.0"
}

