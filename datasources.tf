data "aws_ami" "ubuntu18" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "image-id"
    values = ["ami-0a97be4c4be6d6cc4"]
  }

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"] # * to use the latest
  }
}
