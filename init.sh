#!/bin/bash

main() {
    createAppDir

    # Local Nginx Setup
    waitForNginx
    deleteNginxFiles
    enableEditing
    serveHTMLFile

    # Environments
    setupPHPEnvironment
    setupNodeEnvironment

    generateSSHKey
}

createAppDir() {
    # Create application directory
    echo "Creating app directory..."
    sudo mkdir -p /home/ubuntu/app
    sudo chmod -R 777 /home/ubuntu/app
}

waitForNginx() {
    # Wait until Nginx is up and running
    echo "Waiting for Nginx to be up..."
    until sudo systemctl is-active --quiet nginx; do
        sleep 1
    done
    echo "Nginx is up and running."
}

deleteNginxFiles() {
    # Delete default Nginx files
    TARGET_DIR="/var/www/html"
    echo "Deleting default Nginx files in $TARGET_DIR..."

    if cd "$TARGET_DIR"; then
        sudo rm -rf ./*
        echo "Deleted all files and directories in $TARGET_DIR."
    else
        echo "Failed to change directory to $TARGET_DIR. Ensure the directory exists."
    fi
}

enableEditing() {
    # Ensure Nginx HTML directory is writable
    TARGET_DIR="/var/www/html"
    echo "Enabling editing permissions for $TARGET_DIR..."
    sudo chmod -R 777 $TARGET_DIR
}

serveHTMLFile() {
    # Serve the HTML file from the app directory
    SOURCE_DIR="/home/ubuntu/app"
    TARGET_DIR="/var/www/html"
    echo "Copying files from $SOURCE_DIR to $TARGET_DIR..."

    if [ -d "$SOURCE_DIR" ]; then
        sudo cp -r $SOURCE_DIR/* $TARGET_DIR
        echo "HTML files have been copied to $TARGET_DIR."
    else
        echo "Source directory $SOURCE_DIR does not exist."
    fi
}

setupPHPEnvironment() {
    # Set up PHP environment
    echo "Setting up PHP environment..."
    /bin/bash -c "$(curl -fsSL https://php.new/install/linux)"
    source $HOME/.bashrc
}

setupNodeEnvironment() {
    # Set up Node.js environment
    echo "Setting up Node.js environment..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    nvm install --lts
    npm install -g pnpm
}

generateSSHKey() {
    ssh-keygen -t rsa -f ~/.ssh/id_rsa -P "" && clear && echo "Copy and paste the public key below to your GitHub account:\n\e[32m$(cat ~/.ssh/id_rsa.pub) \e[0m" # Green
}

 main
