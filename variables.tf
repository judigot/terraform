/* 
Create these files to override the default variables:
  terraform.tfvars
  production.tfvars
  development.tfvars
*/

variable "instance_type" {
  type = string
  default = "t2.micro"
}

variable "username" {
  type = string
  default = "ubuntu"
}

variable "region" {
  type = string
  default = "us-west-2"
}

variable "ssh_key_name" {
  type = string
  default = "judigot"
}

variable "host_os" {
  type = string
  default = "windows"
}