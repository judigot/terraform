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
  vpc_id = aws_vpc.main.id // Attach IGW to the VPC for internet access.

  tags = {
    Name = "dev-igw"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id // Associate the route table with our VPC.

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id // Directs traffic to the IGW.
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
  route_table_id = aws_route_table.public_rt.id // Links Subnet 1 with our route table.
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
  route_table_id = aws_route_table.public_rt.id // Links Subnet 2 with our route table.
}

resource "aws_security_group" "sg" {
  count       = var.enable_ec2 ? 1 : 0
  vpc_id      = aws_vpc.main.id
  name        = "App Security Group" # Optional
  description = "App security group"

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"] # Replace with your IP/range
    self             = false
    description      = "SSH: Allow SSH access from any IP address. For security reasons, consider restricting this to known IP addresses or ranges." # Required
    security_groups  = []                                                                                                                            # Required
    ipv6_cidr_blocks = []                                                                                                                            # Required
    prefix_list_ids  = []                                                                                                                            # Required
  }

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    self             = false
    description      = "HTTP: Allow HTTP traffic from any IP address."
    security_groups  = [] # Required
    ipv6_cidr_blocks = [] # Required
    prefix_list_ids  = [] # Required
  }

  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    self             = false
    description      = "HTTPS: Allow HTTPS traffic from any IP address."
    security_groups  = [] # Required
    ipv6_cidr_blocks = [] # Required
    prefix_list_ids  = [] # Required
  }

  # Windows only
  ingress {
    from_port   = 3389 # RDP port
    to_port     = 3389 # RDP port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Open to all IPs (not recommended for production). Replace with your IP, e.g., "YOUR_PUBLIC_IP/32"
    description = "Allow Windows Remote Desktop Protocol (RDP)"
  }

  # Dynamic ingress rule for allowing application ports (see "app_ports" in variables.tf)
  dynamic "ingress" {
    for_each = var.app_ports
    content {
      from_port        = ingress.value
      to_port          = ingress.value
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"] # Allow traffic from anywhere (adjust as needed)
      self             = false
      description      = "Allow access to application on port ${ingress.value}"
      security_groups  = [] # Required
      ipv6_cidr_blocks = [] # Required
      prefix_list_ids  = [] # Required
    }
  }

  # Default egress rule for allowing all outbound traffic
  egress = [{
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"] # Can have multiple IPs
    self             = false
    description      = "Allow outbound traffic"
    ipv6_cidr_blocks = [] # Required
    prefix_list_ids  = [] # Required
    security_groups  = [] # Required
  }]
}
