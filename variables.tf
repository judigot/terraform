/* 
Create these files to override the default variables:
  env.production.tfvars
  env.development.tfvars

  *env. prefix is just to group these files together
*/

variable "db_name" {
  description = "Database name"
  type        = string
  default = "app_db"
}

variable "db_username" {
  description = "Database username"
  type        = string
  default = "root"
}

variable "db_password" {
  description = "Database password"
  type        = string
  default = "password"
  sensitive   = true  # Mark this variable as sensitive to avoid accidental exposure
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "disk_size" {
  type = number

  # t2.micro
  default = 10 # GB
}

variable "volume_type" {
  type    = string
  default = "gp3"
}

variable "username" {
  type    = string
  default = "ubuntu" # ubuntu is the default and can not be changed unless you create another user inside the instance
}

variable "region" {
  type    = string
  
  # default = "us-east-1" # N. Virginia
  default = "us-east-2" # Ohio
  # default = "us-west-1" # N. California
  # default = "us-west-2" # Oregon

  # default = "ap-southeast-1" # Singapore
}

variable "ssh_key_name" {
  type    = string
  default = "aws.pem"
}

variable "initial_script" {
  type    = string
  default = "init"
}

variable "create_database" {
  description = "Whether to create the RDS instance"
  type        = bool
  default     = false
}

variable "app_ports" {
  description = "List of ports to allow for the applications"
  type        = list(number)
  default     = [
    3000,  # Node.js, React, Express.js
    5000,  # Flask, Django, Node.js
    8080,  # Tomcat, Spring Boot, Node.js
    8000,  # Laravel, Django, PHP built-in server, Apache Tomcat
    3306,  # MySQL, MariaDB
    5432,  # PostgreSQL
    6379,  # Redis
    27017, # MongoDB
    9200,  # Elasticsearch
    9000   # SonarQube, FastAPI
  ]
}