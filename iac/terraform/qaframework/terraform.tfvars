bucket_name = "aws-glue-job-test-vijay-app-jenkins"

default_args = {
    "--TempDir" = "s3://${var.glue_s3_bucket}/temp" ,
    "--extra-py-files" = "s3://${var.glue_s3_bucket}/jar/sample.jar.zip",
    "--extra-files" = "s3://${var.glue_s3_bucket}/config/test.json",
    "--additional-python-modules" = "great_expectations, openpyxl"
}