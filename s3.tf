# s3.tf
# Hardcoded, minimal bootstrap S3 bucket + Init.ps1 upload.
# Put this file in the same folder as your other *.tf files (e.g., main.tf).
# Also put Init.ps1 in the same folder so ${path.module}/Init.ps1 resolves.

import {
  to = aws_s3_bucket.bootstrap
  id = "apportable-bootstrap-init-ps1"
}

resource "aws_s3_bucket" "bootstrap" {
  bucket = "apportable-bootstrap-init-ps1"
}

resource "aws_s3_object" "init_ps1" {
  bucket = aws_s3_bucket.bootstrap.bucket
  key    = "Init.ps1"
  source = "${path.module}/Init.ps1"
}
