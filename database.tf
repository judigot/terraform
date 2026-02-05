locals {
  db_engine_port    = var.db_engine == "mysql" ? 3306 : 5432
  db_identifier     = var.db_engine == "mysql" ? "mysql" : "postgres"
  db_scheme         = var.db_engine == "mysql" ? "mysql" : "postgresql"
  db_engine_name    = var.db_engine == "mysql" ? "mysql" : "postgres"
  create_database   = var.create_database || var.enable_rds
  db_engine_version = var.db_engine_version != "" ? var.db_engine_version : (var.db_engine == "mysql" ? "8.0" : "16.3")
}

resource "aws_db_subnet_group" "db_subnet_group" {
  count      = local.create_database ? 1 : 0
  name       = "database_subnet_group"
  subnet_ids = [aws_subnet.public_subnet_1[0].id, aws_subnet.public_subnet_2[0].id] // Groups our subnets for the RDS instance.

  tags = {
    Name = "Database subnet group"
  }
}

resource "aws_security_group" "rds_sg" {
  count       = local.create_database ? 1 : 0
  name        = "Database Security Group" # Optional
  description = "Database security group"
  vpc_id      = aws_vpc.main[0].id // Ensure the SG is within our VPC.

  ingress {
    from_port = local.db_engine_port
    to_port   = local.db_engine_port
    protocol  = "tcp"
    cidr_blocks = [
      "0.0.0.0/0",  // Allow database access from anywhere (consider narrowing this for production).
      "10.0.2.0/32" // Also allow from a specific internal subnet for direct access.
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] // Permit all outbound traffic from the RDS.
  }

  tags = {
    Name = "RDS Security Group"
  }
}

resource "aws_db_instance" "database" {
  count          = local.create_database ? 1 : 0
  identifier     = local.db_identifier
  engine         = local.db_engine_name
  engine_version = var.db_engine_version

  db_name               = var.db_name
  username              = var.db_username
  password              = var.db_password
  allocated_storage     = 20
  max_allocated_storage = 100 # Enables storage autoscaling as needed.

  storage_type           = "gp3" // Utilizes SSD storage for better performance.
  instance_class         = "db.r5.large"
  multi_az               = false                                                 // Consider setting to true for production for higher availability.
  vpc_security_group_ids = [aws_security_group.rds_sg[count.index].id]           // Applies our SG to the RDS instance.
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group[count.index].name // Assigns our DB subnet group.
  publicly_accessible    = true                                                  // Allows the RDS instance to be accessible from the internet.
  skip_final_snapshot    = true                                                  // Caution: Skipping final snapshot can lead to data loss on delete.

  tags = {
    Name = "Database"
  }
}
