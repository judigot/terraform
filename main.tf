resource "aws_key_pair" "auth" {
  key_name   = var.ssh_key_name
  public_key = file("~/.ssh/${var.ssh_key_name}.pub")
}

resource "aws_instance" "app_server" {
  ami           = data.aws_ami.server_os.id
  instance_type = var.instance_type

  # SSH Key
  key_name = aws_key_pair.auth.key_name # ID/Keyname

  # Security Group
  vpc_security_group_ids = [aws_security_group.sg.id]

  # Subnet ID
  subnet_id = aws_subnet.public_subnet_1.id

  # Override the default drive size
  root_block_device {
    volume_type = var.volume_type
    volume_size = var.disk_size # GB
    delete_on_termination = true
  }

  tags = {
    "Name" = "App Server"
  }

  connection {
    type        = "ssh"
    user        = var.username
    private_key = file("~/.ssh/${var.ssh_key_name}")
    host        = self.public_ip
  }

  #==========PROJECT BOOTSTRAPPING==========#
  user_data = file("install.sh")
  #==========PROJECT BOOTSTRAPPING==========#
}

resource "null_resource" "post_build" {
  depends_on = [aws_instance.app_server]

  connection {
    type        = "ssh"
    user        = var.username
    private_key = file("~/.ssh/${var.ssh_key_name}")
    host        = aws_instance.app_server.public_ip
  }
  provisioner "file" {
    source      = "${path.module}/${var.initial_script}.sh"
    destination = "/home/ubuntu/${var.initial_script}.sh"
  }
  provisioner "file" {
    source      = "${path.module}/app"
    destination = "/home/ubuntu/app"
  }
  provisioner "remote-exec" {
    on_failure = continue

    inline = [
      "cd /home/ubuntu",
      "sh ${var.initial_script}.sh"
    ]
  }
}

resource "null_resource" "setup_ssh_config" {
  # Ensures this runs after the EIP is associated
  depends_on = [aws_instance.app_server]

  # Optionally, use triggers to control when the provisioner should run
  triggers = {
    ip_address = aws_instance.app_server.public_ip
  }

  provisioner "local-exec" {
    command = templatefile(data.external.os_check.result["is_windows"] == "true" ? "ssh-config-windows.tpl" : "ssh-config-mac-linux.tpl", {
      hostname     = aws_instance.app_server.public_ip,
      user         = var.username,
      identityfile = "~/.ssh/${var.ssh_key_name}"
    })

    interpreter = data.external.os_check.result["is_windows"] == "true" ? ["powershell", "-Command"] : ["bash", "-c"]
  }
}

# resource "null_resource" "open_instance_in_vs_code" {
#   # Ensures this runs after the EIP is associated
#   # depends_on = [aws_eip.ip_address]
#   depends_on = [aws_instance.app_server]

#   # Optionally, use triggers to control when the provisioner should run
#   triggers = {
#     always_run = timestamp()
#     ip_address = aws_instance.app_server.public_ip
#   }

#   provisioner "local-exec" {
#     # command = "code --remote ssh-remote+${var.username}@${self.triggers.ip_address}"

#     command = <<EOT
# if uname -s | grep -iq 'mingw\\|cygwin\\|msys'; then
#   Powershell -Command "code --remote ssh-remote+${var.username}@${self.triggers.ip_address}"
# else
#   echo "ssh -i ~/.ssh/${var.ssh_key_name} ${var.username}@${self.triggers.ip_address}"
# fi
# EOT

#     interpreter = ["bash", "-c"]
#   }
# }
