# Add an Elastic IP to instance
# resource "aws_eip" "ip_address" {
#   instance = aws_instance.app_server.id
#   domain   = "vpc"
# }

# resource "null_resource" "setup_ssh_config" {
#   # Ensures this runs after the EIP is associated
#   depends_on = [aws_eip.ip_address]

#   # Optionally, use triggers to control when the provisioner should run
#   triggers = {
#     eip_address = aws_eip.ip_address.public_ip
#   }

#   provisioner "local-exec" {
#     command = templatefile("ssh-config-${var.host_os}.tpl", {
#       hostname     = aws_eip.ip_address.public_ip,
#       user         = var.username,
#       identityfile = "~/.ssh/${var.ssh_key_name}"
#     })
#     interpreter = var.host_os == "linux" ? ["bash", "-c"] : ["Powershell", "-Command"]
#   }
# }

#==========NAME SERVERS==========#
# resource "aws_route53_zone" "judigot_zone" {
#   name = "judigot.com"
# }
# resource "aws_route53_record" "judigot_a_record" {
#   zone_id = aws_route53_zone.judigot_zone.zone_id
#   name    = "judigot.com"
#   type    = "A"
#   ttl     = "60"
#   records = [aws_eip.ip_address.public_ip]
# }
# resource "aws_route53_record" "judigot_www_a_record" {
#   zone_id = aws_route53_zone.judigot_zone.zone_id
#   name    = "www.judigot.com"
#   type    = "A"
#   ttl     = "60"
#   records = [aws_eip.ip_address.public_ip]
# }
#==========NAME SERVERS==========#