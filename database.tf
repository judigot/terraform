resource "aws_vpc" "db_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "dev"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.db_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2a" // Specify AZ if needed, uncomment as necessary.

  tags = {
    Name = "dev-public"
  }
}

resource "aws_subnet" "public_subnet_3" {
  vpc_id                  = aws_vpc.db_vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2b" // Specify AZ if needed, uncomment as necessary.

  tags = {
    Name = "dev-public"
  }
}

resource "aws_internet_gateway" "internet_gateway_db" {
  vpc_id = aws_vpc.db_vpc.id  // Attach IGW to the VPC for internet access.

  tags = {
    Name = "db-igw"
  }
}

# Define a route table for managing traffic within the VPC and for internet-bound traffic.
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.db_vpc.id  // Associate the route table with our VPC.

  # Route for directing internal VPC traffic.
  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"  // Uses 'local' to keep traffic within the VPC.
  }

  # Route for directing internet-bound traffic out through the Internet Gateway.
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway_db.id  // Directs traffic to the IGW.
  }

  tags = {
    Name = "public_route_table"
  }
}

# Associate the custom route table with our public subnets to enable internet access.
resource "aws_route_table_association" "public_route_table_assoc_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id  // Links Subnet 2 with our route table.
}

resource "aws_route_table_association" "public_route_table_assoc_3" {
  subnet_id      = aws_subnet.public_subnet_3.id
  route_table_id = aws_route_table.public_route_table.id  // Links Subnet 3 with our route table.
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "main"
  subnet_ids = [aws_subnet.public_subnet_2.id, aws_subnet.public_subnet_3.id]  // Groups our subnets for the RDS instance.

  tags = {
    Name = "Database subnet group"
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "rds-database-sg"
  description = "Security group for RDS database instance"
  vpc_id      = aws_vpc.db_vpc.id  // Ensure the SG is within our VPC.

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [
      "0.0.0.0/0",  // Allow database access from anywhere (consider narrowing this for production).
      "10.0.2.0/32" // Also allow from a specific internal subnet for direct access.
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  // Permit all outbound traffic from the RDS.
  }

  tags = {
    Name = "RDS Security Group"
  }
}

resource "aws_db_instance" "myrds" {

  identifier              = "postgres"
  engine                  = "postgres"
  engine_version          = "14"

  # identifier              = "mysql"
  # engine                  = "mysql"
  # engine_version          = "8"

  username                = "root"
  password                = "password"
  allocated_storage       = 20
  max_allocated_storage   = 100 # Enables storage autoscaling as needed.

  storage_type            = "gp2"  // Utilizes SSD storage for better performance.
  instance_class          = "db.t4g.micro"  // Selected for cost-efficiency; adjust based on need.
  multi_az                = false  // Consider setting to true for production for higher availability.
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]  // Applies our SG to the RDS instance.
  db_subnet_group_name    = aws_db_subnet_group.db_subnet_group.name  // Assigns our DB subnet group.
  db_name                 = "dbname"
  publicly_accessible     = true  // Allows the RDS instance to be accessible from the internet.
  skip_final_snapshot     = true  // Caution: Skipping final snapshot can lead to data loss on delete.

  tags = {
    Name = "Database"
  }
}
