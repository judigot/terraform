# s3.tf
# Bootstrap S3 bucket + Init.ps1 upload for Windows instances.

resource "aws_s3_bucket" "bootstrap" {
  bucket = "apportable-bootstrap-init-ps1"
}

resource "aws_s3_object" "init_ps1" {
  bucket = aws_s3_bucket.bootstrap.bucket
  key    = "Init.ps1"
  source = "${path.module}/templates/Init.ps1"
}
