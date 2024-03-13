# Create a VPC (Virtual Private Cloud)
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "dev"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.region}a"

  tags = {
    Name = "dev-public"
  }

}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "dev-igw"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "dev_public_rt"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0" # All IP addresses will hit this gateway
  gateway_id             = aws_internet_gateway.internet_gateway.id
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "sg" {
  vpc_id      = aws_vpc.main.id
  # name        = "dev_sg" # Optional
  description = "Dev security group"

  ingress = [{
    cidr_blocks      = ["0.0.0.0/0"] # Can have multiple IPs
    description      = ""            # Required
    from_port        = 0
    ipv6_cidr_blocks = [] # Required
    prefix_list_ids  = [] # Required
    protocol         = "-1"
    security_groups  = [] # Required
    self             = false
    to_port          = 0
  }]

  egress = [{
    cidr_blocks      = ["0.0.0.0/0"] # Can have multiple IPs
    description      = ""            # Required
    from_port        = 0
    ipv6_cidr_blocks = [] # Required
    prefix_list_ids  = [] # Required
    protocol         = "-1"
    security_groups  = [] # Required
    self             = false
    to_port          = 0
  }]
}