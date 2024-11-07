# Add an Elastic IP to instance
# resource "aws_eip" "ip_address" {
#   instance = aws_instance.app_server.id
#   domain   = "vpc"
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