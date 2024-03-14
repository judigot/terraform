# Create a VPC (Virtual Private Cloud)
# "main" is for terraform reference only and noy used anywhere in AWS

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "dev"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.main.id  // Attach IGW to the VPC for internet access.

  tags = {
    Name = "dev-igw"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id  // Associate the route table with our VPC.

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id  // Directs traffic to the IGW.
  }

  tags = {
    Name = "public_rt"
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.region}a" // Specify AZ if needed, uncomment as necessary.

  tags = {
    Name = "dev-public"
  }
}

# Associate the custom route table with our public subnets to enable internet access.
resource "aws_route_table_association" "public_rt_assoc_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id  // Links Subnet 1 with our route table.
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.region}b" // Specify AZ if needed, uncomment as necessary.

  tags = {
    Name = "dev-public"
  }
}

resource "aws_route_table_association" "public_rt_assoc_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id  // Links Subnet 2 with our route table.
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "main"
  subnet_ids = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]  // Groups our subnets for the RDS instance.

  tags = {
    Name = "Database subnet group"
  }
}

resource "aws_security_group" "sg" {
  vpc_id      = aws_vpc.main.id
  # name        = "dev_sg" # Optional
  description = "Dev security group"

  ingress = [
    {
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"] # Replace with your IP/range
      self             = false
      description      = "SSH" # Required
      security_groups  = [] # Required
      ipv6_cidr_blocks = [] # Required
      prefix_list_ids  = [] # Required
    },
    {
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      self             = false
      description      = "HTTP" # Required
      security_groups  = [] # Required
      ipv6_cidr_blocks = [] # Required
      prefix_list_ids  = [] # Required
    },
    {
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      self             = false
      description      = "HTTPS" # Required
      security_groups  = [] # Required
      ipv6_cidr_blocks = [] # Required
      prefix_list_ids  = [] # Required
    }
  ]


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