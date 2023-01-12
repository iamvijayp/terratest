bucket_name = "${local.name}-aws-glue-job-test-vijay-app-jenkins"

default_args = {
    "--TempDir" = "s3://aws-glue-job-test-vijay-app-jenkins/temp" ,
    "--extra-py-files" = "s3://aws-glue-job-test-vijay-app-jenkins/jar/sample.jar.zip",
    "--extra-files" = "s3://aws-glue-job-test-vijay-app-jenkins/config/test.json",
    "--additional-python-modules" = "great_expectations, openpyxl"
}