output "dev_ip" {
  value = aws_instance.app_server.public_ip
}

output "ssh_command" {
  value = "ssh -i ~/.ssh/${var.ssh_key_name} -o StrictHostKeyChecking=no ${var.username}@${aws_instance.app_server.public_ip}"
}

output "db_endpoint" {
  description = "The connection endpoint for the RDS instance"
  value       = var.create_database ? replace(aws_db_instance.database[0].endpoint, ":${aws_db_instance.database[0].port}", "") : ""
}

output "db_username" {
  description = "The username for the RDS database"
  value       = var.create_database ? var.db_username : ""
}

output "db_password" {
  description = "The password for the RDS database"
  value       = var.create_database ? var.db_password : ""
  sensitive   = true  # Prevents the password from being shown in plain text in the output
}

output "db_port" {
  description = "The port for the RDS instance"
  value       = var.create_database ? aws_db_instance.database[0].port : ""
}

output "db_connection_string" {
  description = "The full PostgreSQL connection string"
  value       = var.create_database ? "postgresql://${var.db_username}:[YOUR-PASSWORD]@${aws_db_instance.database[0].endpoint}/${var.db_name}" : 0
}


# output "public_ip" {
#   value = aws_eip.ip_address.public_ip
# }

# output "name_servers" {
#   value = aws_route53_zone.judigot_zone.name_servers
# }