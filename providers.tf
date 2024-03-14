terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      # version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "${var.region}"
  # shared_config_files = ["~/.aws/credentials"] # If not set, the default is ["~/.aws/credentials"]
  # shared_credentials_files = ["~/.aws/credentials"] # If not set, the default is ["~/.aws/credentials"]
  # profile                  = "admin" # [default] profile name contained in ~/.aws/credentials
}
