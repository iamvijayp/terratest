bucket_name = "aws-glue-job-test-vijay-app-jenkins"

default_args = {
    "--TempDir" = "s3://${module.s3bucket.s3-bucketname}/temp" ,
    "--extra-py-files" = "s3://${module.s3bucket.s3-bucketname}/jar/sample.jar.zip",
    "--extra-files" = "s3://${module.s3bucket.s3-bucketname}/config/test.json",
    "--additional-python-modules" = "great_expectations, openpyxl"
}