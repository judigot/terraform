output "dev_ip" {
  value = aws_instance.dev_server.public_ip
}

# output "public_ip" {
#   value = aws_eip.ip_address.public_ip
# }

# output "name_servers" {
#   value = aws_route53_zone.judigot_zone.name_servers
# }