/* 
Create these files to override the default variables:
  terraform.tfvars
  production.tfvars
  development.tfvars
*/

variable "instance_type" {
  type = string
  # default = "t2.micro"
  default = "c5ad.large"
}
variable "disk_size" {
  type = number

  # t2.micro
  # default = 10 # GB

  # c5ad.large
  default = 75 # GB
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
  default = "id_rsa"
}

variable "host_os" {
  type = string
  default = "windows"
}
