resource "aws_db_subnet_group" "db_subnet_group" {
  count = var.create_rds_instance ? 1 : 0
  name       = "database_subnet_group"
  subnet_ids = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id] // Groups our subnets for the RDS instance.

  tags = {
    Name = "Database subnet group"
  }
}

resource "aws_security_group" "rds_sg" {
  count = var.create_rds_instance ? 1 : 0
  name        = "Database Security Group" # Optional
  description = "Database security group"
  vpc_id      = aws_vpc.main.id  // Ensure the SG is within our VPC.

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

resource "aws_db_instance" "database" {
  count = var.create_rds_instance ? 1 : 0
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
  # instance_class          = "db.t4g.micro"  // Selected for cost-efficiency; adjust based on need.
  instance_class          = "db.r5.large"
  multi_az                = false  // Consider setting to true for production for higher availability.
  vpc_security_group_ids  = [aws_security_group.rds_sg[count.index].id]  // Applies our SG to the RDS instance.
  db_subnet_group_name    = aws_db_subnet_group.db_subnet_group[count.index].name  // Assigns our DB subnet group.
  db_name                 = "app_database"
  publicly_accessible     = true  // Allows the RDS instance to be accessible from the internet.
  skip_final_snapshot     = true  // Caution: Skipping final snapshot can lead to data loss on delete.

  tags = {
    Name = "Database"
  }
}
