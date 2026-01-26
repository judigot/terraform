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
