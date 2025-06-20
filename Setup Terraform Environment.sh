#!/bin/bash

main() {
    update_packages
    install_terraform
    generate_github_ssh
    generate_aws_pem
    setup_aws_credentials_stub
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
    mkdir -p ~/.ssh
    ssh-keygen -t rsa -f ~/.ssh/id_rsa -P "" && chmod 600 ~/.ssh/id_rsa && clear && echo -e "Copy and paste the public key below to your GitHub account:\n\n\e[32m$(cat ~/.ssh/id_rsa.pub) \e[0m\n" # Green
}

generate_aws_pem() {
    echo "Generating AWS PEM key..."
    mkdir -p ~/.ssh
    ssh-keygen -t rsa -b 2048 -m PEM -f ~/.ssh/aws.pem -P ""
    ssh-keygen -y -f ~/.ssh/aws.pem > ~/.ssh/aws.pem.pub
    chmod 600 ~/.ssh/aws.pem
    echo "Generated ~/.ssh/aws.pem and ~/.ssh/aws.pem.pub"
}

setup_aws_credentials_stub() {
    echo "Setting up ~/.aws/credentials..."
    mkdir -p ~/.aws
    CREDENTIALS_FILE=~/.aws/credentials

    if [ ! -f "$CREDENTIALS_FILE" ]; then
        cat <<EOF > "$CREDENTIALS_FILE"
[default]
aws_access_key_id =
aws_secret_access_key =
region = ap-southeast-1
EOF
        echo "Created blank AWS credentials file at ~/.aws/credentials"
    else
        echo "AWS credentials file already exists. Skipping..."
    fi
}

run_terraform_init() {
    echo "Running terraform init..."
    terraform init
}

main
