# resource "aws_key_pair" "auth" {
#   key_name   = var.ssh_key_name
#   public_key = file("~/.ssh/${var.ssh_key_name}.pub")
# }

# resource "null_resource" "create_ssh_symlink" {
#   triggers = {
#     always_run = "${timestamp()}"
#   }

#   provisioner "local-exec" {
#   command = <<-EOT
#     [ -d "${var.ssh_symlink}" ] && rm -rf "${var.ssh_symlink}"
#     if command -v uname > /dev/null; then
#       # Assume Unix-like OS
#       if [ ! -L "${path.module}/${var.ssh_symlink}" ]; then
#         ln -sfn "$HOME/.ssh" "${path.module}/${var.ssh_symlink}"
#       fi
#     else
#       # Assume Windows
#       powershell.exe -Command "if (!(Test-Path -PathType SymbolicLink -Path '$env:USERPROFILE\\Desktop\\${var.ssh_symlink}')) { New-Item -ItemType SymbolicLink -Path '$env:USERPROFILE\\Desktop\\${var.ssh_symlink}' -Target '$env:USERPROFILE\\.ssh' }"
#     fi
#   EOT
#   interpreter = ["bash", "-c"]
# }

# }

# resource "aws_instance" "dev_server" {
#   instance_type = var.instance_type
#   ami           = data.aws_ami.ubuntu-2204.id

#   # count = 1

#   # SSH Key
#   key_name = aws_key_pair.auth.key_name # ID/Keyname

#   # Security Group
#   vpc_security_group_ids = [aws_security_group.sg.id]

#   # Subnet ID
#   subnet_id = aws_subnet.public_subnet.id

#   # Override the default drive size
#   root_block_device {
#     volume_size = var.disk_size # GB
#   }

#   tags = {
#     "Name" = "Development Server"
#   }

#   #==========PROJECT BOOTSTRAPPING==========#
#   #=====DOCKER=====#
#   user_data = file("user_data.sh")
#   #=====DOCKER=====#
#   #==========PROJECT BOOTSTRAPPING==========#

#   #==========POST-BUILD SCRIPT==========#
#   provisioner "file" {
#     source = "${path.module}/${var.initial_script}.sh"
#     destination = "/home/ubuntu/${var.initial_script}.sh"

#     connection {
#       type        = "ssh"
#       user        = var.username
#       private_key = file("${path.module}/${var.ssh_symlink}/${var.ssh_key_name}")
#       host        = self.public_ip
#     }
#   }

#   provisioner "remote-exec" {
#     on_failure = continue

#     inline = [
#       "cd /home/ubuntu",
#       # "chmod +x /tmp/${var.initial_script}.sh",
#       "sh ${var.initial_script}.sh"
#       # "sudo sh /home/ubuntu/${var.initial_script}.sh"
#     ]

#     connection {
#       type        = "ssh"
#       user        = var.username
#       private_key = file("${path.module}/${var.ssh_symlink}/${var.ssh_key_name}")
#       host        = self.public_ip
#     }
#   }
#   #==========POST-BUILD SCRIPT==========#
# }

# # Add an Elastic IP to instance
# resource "aws_eip" "ip_address" {
#   instance = aws_instance.dev_server.id
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
