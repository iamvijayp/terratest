resource "aws_s3_bucket" "s3bucket" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_public_access_block" "private" {
  bucket = aws_s3_bucket.s3bucket.id

  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption_config" {
  bucket = aws_s3_bucket.s3bucket.id

  rule {
    apply_server_side_encryption_by_default{
        sse_algorithm = "AES256"
    }
  }
}