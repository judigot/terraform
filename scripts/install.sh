#!/bin/bash

main() {
    updateSystem
    installDocker
    installZipExtractors
    installNginx
}

updateSystem() {
    # Update and upgrade the system
    echo "Updating and upgrading the system..."
    sudo apt update -y && sudo apt upgrade -y
}

installDocker() {
    # Install Docker
    echo "Installing Docker..."
    sudo apt install -y ca-certificates curl gnupg lsb-release
    sudo mkdir -m 0755 -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo systemctl enable docker
    sudo systemctl start docker
    sudo usermod -aG docker $USER
}

installZipExtractors() {
    # Install unzip and 7zip
    echo "Installing unzip and 7zip extractors..."
    sudo apt install -y unzip p7zip p7zip-full
}

installNginx() {
    # Install and start Nginx
    echo "Installing and starting Nginx..."
    sudo apt install -y nginx
    sudo systemctl enable nginx
    sudo systemctl start nginx
}

main
