/*
Search this in AMI Catalog > Community AMIs:
  ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server
*/

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical Ltd. Account Number

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"] # * to use the latest
  }
}

data "external" "os_check" {
  program = ["sh", "-c", "echo -n $(uname -s | grep -iq 'mingw\\|cygwin\\|msys' && echo '{\"is_windows\":\"true\"}' || echo '{\"is_windows\":\"false\"}')"]
}
