#!/bin/bash

main() {
    update_packages
    install_terraform
    generate_github_ssh
    run_terraform_init
}

update_packages() {
    echo "Updating packages..."
    sudo apt-get update -y
    sudo apt-get install -y unzip curl gnupg software-properties-common lsb-release zip
}

install_terraform() {
    echo "Installing Terraform..."
    curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o hashicorp.gpg
    sudo install -o root -g root -m 644 hashicorp.gpg /usr/share/keyrings/hashicorp.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
        sudo tee /etc/apt/sources.list.d/hashicorp.list > /dev/null
    sudo apt-get update -y
    sudo apt-get install -y terraform
    rm -f hashicorp.gpg
    terraform -version && echo "Terraform installed."
}

generate_github_ssh() {
    echo "Generating GitHub SSH key..."
    ssh-keygen -t rsa -f ~/.ssh/id_rsa -P "" -q
    chmod 600 ~/.ssh/id_rsa
    echo -e "\nPublic key (add to GitHub):\n"
    cat ~/.ssh/id_rsa.pub
    echo
}

run_terraform_init() {
    echo "Running terraform init..."
    terraform init
}

main
