resource "aws_key_pair" "auth" {
  key_name   = var.ssh_key_name
  public_key = var.ssh_public_key
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
  user_data_base64 = var.os == "windows" ? base64encode(templatefile("${path.module}/init.windows.ps1", {
    windows_admin_password = var.windows_admin_password
    init_ps1_url           = data.external.init_ps1_presign.result.url
  })) : null
  
  # user_data_base64 = var.os == "windows" ? base64encode(templatefile("${path.module}/init.windows.ps1", { windows_admin_password = var.windows_admin_password })) : null
  user_data        = var.os != "windows" ? file("install.sh") : null
  #==========PROJECT BOOTSTRAPPING==========#
}

# Waits for Nginx to be available before proceeding
resource "null_resource" "post_build" {
  count = var.os == "windows" ? 0 : 1
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

# # Waits for Windows password to be available before proceeding
# resource "null_resource" "post_build_windows" {
#   count      = var.os == "windows" ? 1 : 0
#   depends_on = [aws_instance.app_server]

#   provisioner "local-exec" {
#     command = <<EOT
# echo "Waiting for Windows password to become available..."

# while true; do
#   PASSWORD=$(aws ec2 get-password-data \
#     --instance-id ${aws_instance.app_server.id} \
#     --priv-launch-key ~/.ssh/${var.ssh_key_name} \
#     --region ${var.region} \
#     --profile admin \
#     --query PasswordData \
#     --output text)

#   if [ "$PASSWORD" != "None" ] && [ -n "$PASSWORD" ]; then
#     echo ""
#     echo "username:"
#     echo "Administrator"
#     echo "password:"
#     echo "$PASSWORD"
#     break
#   fi

#   echo "Still waiting... retrying in 10s..."
#   sleep 10
# done
# EOT
#     interpreter = ["bash", "-c"]
#   }
# }

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
