bucket_name = "aws-glue-job-test-vijay-app-jenkins"

default_args = {
    "--TempDir" = "s3://${bucket_name}/temp" ,
    "--extra-py-files" = "s3://${bucket_name}/jar/sample.jar.zip",
    "--extra-files" = "s3://${bucket_name}/config/test.json",
    "--additional-python-modules" = "great_expectations, openpyxl"
}