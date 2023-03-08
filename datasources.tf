data "aws_ami" "ubuntu18" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "image-id"
    values = ["ami-0735c191cf914754d"]
  }

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"] # * to use the latest
  }
}
