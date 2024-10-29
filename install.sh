#!/bin/bash

#==========DOCKER==========#
sudo apt update
sudo apt install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
sudo mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
#==========DOCKER==========#

#==========ZIP EXTRACTORS==========#
sudo apt install -y unzip p7zip p7zip-full
#==========ZIP EXTRACTORS==========#

#==========NGINX==========#
sudo apt install -y nginx
#==========NGINX==========#

#==========PHP, COMPOSER, & LARAVEL INSTALLER==========#
/bin/bash -c "$(curl -fsSL https://php.new/install/linux)"

source $HOME/.bashrc
#==========PHP, COMPOSER, & LARAVEL INSTALLER==========#

#==========NVM & NODE.JS==========#
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh | bash
#==========NVM & NODE.JS==========#