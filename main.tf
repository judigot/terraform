resource "aws_key_pair" "auth" {
  key_name   = var.ssh_key_name
  public_key = file("~/.ssh/${var.ssh_key_name}.pub")
}

resource "aws_instance" "dev_server" {
  instance_type = var.instance_type
  ami           = data.aws_ami.ubuntu-2204.id

  # count = 1

  # SSH Key
  key_name = aws_key_pair.auth.key_name # ID/Keyname

  # Security Group
  vpc_security_group_ids = [aws_security_group.sg.id]

  # Subnet ID
  subnet_id = aws_subnet.public_subnet_1.id

  # Override the default drive size
  root_block_device {
    volume_size = var.disk_size # GB
  }

  tags = {
    "Name" = "Development Server"
  }

  #==========PROJECT BOOTSTRAPPING==========#
  user_data = file("user_data.sh")
  #==========PROJECT BOOTSTRAPPING==========#

  #==========POST-BUILD SCRIPT==========#
  provisioner "file" {
    source = "${path.module}/${var.initial_script}.sh"
    destination = "/home/ubuntu/${var.initial_script}.sh"

    connection {
      type        = "ssh"
      user        = var.username
      private_key = file("~/.ssh/${var.ssh_key_name}")
      host        = self.public_ip
    }
  }

  provisioner "remote-exec" {
    on_failure = continue

    inline = [
      "cd /home/ubuntu",
      # "chmod +x /tmp/${var.initial_script}.sh",
      "sh ${var.initial_script}.sh"
      # "sudo sh /home/ubuntu/${var.initial_script}.sh"
    ]

    connection {
      type        = "ssh"
      user        = var.username
      private_key = file("~/.ssh/${var.ssh_key_name}")
      host        = self.public_ip
    }
  }
  #==========POST-BUILD SCRIPT==========#
  
}

resource "null_resource" "open_remote_connection" {
  # Ensures this runs after the EIP is associated
  # depends_on = [aws_eip.ip_address]
  depends_on = [aws_instance.dev_server]

  # Optionally, use triggers to control when the provisioner should run
  triggers = {
    always_run = timestamp()
    ip_address = aws_instance.dev_server.public_ip
  }

  provisioner "local-exec" {
        command = "code --remote ssh-remote+${var.username}@${self.triggers.ip_address}"
  }
}