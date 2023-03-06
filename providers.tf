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
  region = "us-west-2"
  # shared_config_files      = ["~/.aws/conf"]
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "default" # [default] profile name contained in ~/.aws/credentials
}

# Create a VPC
# "main" is for terraform reference only and noy used anywhere in AWS
# This resource can be in a separate file called main.tf
# resource "aws_vpc" "main" {
#   cidr_block = "10.0.0.0/16"
# }