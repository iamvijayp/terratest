variable "glue_s3_bucket" {
  default = "aws-glue-job-test-vijay123412"
}
variable "glue_script_s3key" {
  type= string
  default = "glue-compress.py"
}
variable "job_language" {
  description = "Job language"
  default = "python"
}

variable "glue_arn" {
  description = "ARN of the glue-iam service role"
  default = "arn:aws:iam::078535629410:role/aws-glue-terraform-role"
}

variable "glue_job_name" {
  description = "Name of the Glue Job"
  default = "compress-small-files-large-files"
}
variable "glue_script_path" {
  description = "Name of the python script"
  default = "glue-compress.py"
}

variable "default_args" {
  description = "default glue job args"
  type = map(string)
  default = {}
}
