# resource "aws_vpc" "db_vpc" {
#   cidr_block           = "10.0.0.0/16"
#   enable_dns_hostnames = true
#   enable_dns_support   = true

#   tags = {
#     Name = "dev"
#   }
# }

# resource "aws_subnet" "public_subnet_2" {
#   vpc_id                  = aws_vpc.db_vpc.id
#   cidr_block              = "10.0.1.0/24"
#   map_public_ip_on_launch = true
# #   availability_zone       = "us-west-2a"

#   tags = {
#     Name = "dev-public"
#   }

# }

# resource "aws_subnet" "public_subnet_3" {
#   vpc_id                  = aws_vpc.db_vpc.id
#   cidr_block              = "10.0.2.0/24"
#   map_public_ip_on_launch = true
# #   availability_zone       = "us-west-2b"

#   tags = {
#     Name = "dev-public"
#   }

# }

# resource "aws_internet_gateway" "internet_gateway_db" {
#   vpc_id = aws_vpc.db_vpc.id

#   tags = {
#     Name = "db-igw"
#   }
# }

# resource "aws_db_subnet_group" "db_subnet_group" {
#   name       = "main"
#   subnet_ids = [aws_subnet.public_subnet_2.id, aws_subnet.public_subnet_3.id]

#   tags = {
#     Name = "Database subnet group"
#   }
# }

# resource "aws_db_instance" "myrds" {
#     identifier          = "mysql"
#     engine              = "mysql"
#     engine_version      = "8.0.32"
#     username            = "root"
#     password            = "password"
#     allocated_storage   = 20
#     max_allocated_storage = 100 # Storage autoscaling (optional)

#     storage_type        = "gp2" # SSD
#     instance_class      = "db.t4g.micro"
#     # storage_type        = "io1" # SSD
#     # instance_class      = "db.m5d.large"

#     multi_az = false
#     # vpc_security_group_ids = [aws_security_group.sg.id]
#     # db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
#     db_name = "dbname"

#     publicly_accessible = true
#     skip_final_snapshot = true

#     tags = {
#         Name = "MySQL"
#     }
#  }