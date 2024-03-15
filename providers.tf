terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      # version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
  shared_config_files      = data.external.os_check.result["is_windows"] == "true" ? ["~/.aws/config"] : []
  shared_credentials_files = data.external.os_check.result["is_windows"] == "true" ? ["~/.aws/credentials"] : []
  profile                  = "admin" # [default] profile name contained in ~/.aws/credentials
}
