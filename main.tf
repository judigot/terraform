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
  availability_zone       = "us-west-2a"

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

resource "aws_key_pair" "auth" {
  key_name   = var.ssh_key_name
  public_key = file("~/.ssh/${var.ssh_key_name}.pub")
}

resource "aws_instance" "dev_server" {
  instance_type = var.instance_type
  ami           = data.aws_ami.ubuntu-2204.id

  # count = 1

  # SSH Key
  key_name = aws_key_pair.auth.key_name # ID/Keyname

  # Security Group
  vpc_security_group_ids = [aws_security_group.sg.id]

  # Subnet ID
  subnet_id = aws_subnet.public_subnet.id

  # Override the default drive size
  root_block_device {
    volume_size = var.disk_size # GB
  }

  tags = {
    "Name" = "Development Server"
  }

  #==========PROJECT BOOTSTRAPPING==========#
  #=====DOCKER=====#
  user_data = file("docker.tpl")
  #=====DOCKER=====#
  #==========PROJECT BOOTSTRAPPING==========#
}

# Add an Elastic IP to instance
resource "aws_eip" "ip_address" {
  instance = aws_instance.dev_server.id
  vpc      = true

  # Run commands in the host machine after creating the instance
  provisioner "local-exec" {
    # Add EC2 instance to SSH configuration
    command = templatefile("ssh-config-${var.host_os}.tpl", {
      hostname     = self.public_ip, # If you already have a domain name mapped to an IP address, you can use it here
      user         = var.username,
      identityfile = "~/.ssh/${var.ssh_key_name}"
    })
    interpreter = var.host_os == "linux" ? ["bash", "-c"] : ["Powershell", "-Command"]
  }
}