bucket_name = "aws-glue-job-test-vijay-app-jenkins"

default_arguments_forglue = {
    "--TempDir" = "s3://${var.glue_s3_bucket}/temp2" ,
    "--extra-py-files" = "s3://${var.glue_s3_bucket}/jar/sample.jar.zip2",
    "--extra-files" = "s3://${var.glue_s3_bucket}/config/test.json2",
    "--additional-python-modules" = "great_expectations, openpyxl2"
}