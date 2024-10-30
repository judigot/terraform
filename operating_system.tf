/*
Search this in AMI Catalog > Community AMIs:
  ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server

  Windows_Server-2022-English-Full-Base-2024.10.09 - with GUI
  Windows_Server-2022-English-Core-Base-2024.10.09 - command line only (PowerShell)
*/

data "aws_ami" "server_os" {
  most_recent = true

  owners = ["099720109477"] # Canonical Ltd. Account Number
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"] # * to use the latest
  }

  # owners = ["801119661308"] # Windows Account Number
  # filter {
  #   name   = "name"
  #   values = ["Windows_Server-2022-English-Full-Base-*"] # * to use the latest
  # }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

data "external" "os_check" {
  program = ["sh", "-c", "echo -n $(uname -s | grep -iq 'mingw\\|cygwin\\|msys' && echo '{\"is_windows\":\"true\"}' || echo '{\"is_windows\":\"false\"}')"]
}
