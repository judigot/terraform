data "external" "init_ps1_presign" {
  program = [
    "sh",
    "${path.module}/presign-init.sh",
    aws_s3_bucket.bootstrap.bucket,
    "Init.ps1",
    var.region,
    "604800" # 7 days in seconds
  ]
}
