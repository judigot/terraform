# State migration for adding count to existing resources
# These moved blocks tell Terraform to update state addresses when adding count

# EC2 and related resources
moved {
  from = aws_security_group.sg
  to   = aws_security_group.sg[0]
}

moved {
  from = aws_key_pair.auth
  to   = aws_key_pair.auth[0]
}

moved {
  from = aws_instance.app_server
  to   = aws_instance.app_server[0]
}

# Networking resources
moved {
  from = aws_vpc.main
  to   = aws_vpc.main[0]
}

moved {
  from = aws_internet_gateway.internet_gateway
  to   = aws_internet_gateway.internet_gateway[0]
}

moved {
  from = aws_route_table.public_rt
  to   = aws_route_table.public_rt[0]
}

moved {
  from = aws_subnet.public_subnet_1
  to   = aws_subnet.public_subnet_1[0]
}

moved {
  from = aws_subnet.public_subnet_2
  to   = aws_subnet.public_subnet_2[0]
}

moved {
  from = aws_route_table_association.public_rt_assoc_1
  to   = aws_route_table_association.public_rt_assoc_1[0]
}

moved {
  from = aws_route_table_association.public_rt_assoc_2
  to   = aws_route_table_association.public_rt_assoc_2[0]
}
