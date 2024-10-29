#!/bin/bash

main() {
    generateSSH
    createAppDir

    # Local Nginx
    waitForNginx
    deleteNginxFiles
    enableEditing
    serveHTMLFile

    # Environments
    setupPHPEnvironment
    setupNodeEnvironment
}

setupNodeEnvironment() {
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion
    nvm install --lts
    npm install -g pnpm
}

setupPHPEnvironment() {
    /bin/bash -c "$(curl -fsSL https://php.new/install/linux)"
    source $HOME/.bashrc
}

waitForNginx() {
    # Wait until nginx is up and running
    echo "Waiting for Nginx to be up..."
    until sudo systemctl is-active --quiet nginx; do
        sleep 1
    done
    echo "Nginx is up and running."
}

generateSSH() {
    sudo ssh-keygen -t rsa -f ~/.ssh/id_rsa -P "" && echo -e "Copy and paste the public key below to your GitHub account:\n\n\e[32m$(cat ~/.ssh/id_rsa.pub) \e[0m\n" # Green
}

createAppDir() {
    sudo mkdir -p app
    sudo chmod -R 777 app
}

deleteNginxFiles() {
    TARGET_DIR="/var/www/html"

    # Ensure we are in the correct directory before deleting files
    if cd "$TARGET_DIR"; then
        # Delete all files and directories
        sudo rm -rf ./*
        echo "Deleted all files and directories in $TARGET_DIR."
    else
        echo "Failed to change directory to $TARGET_DIR. Ensure the directory exists."
    fi
}

enableEditing() {
    TARGET_DIR="/var/www/html"
    sudo chmod -R 777 $TARGET_DIR
}

serveHTMLFile() {
    # Define source and target directories
    SOURCE_DIR=~/app
    TARGET_DIR=/var/www/html

    # Ensure the source directory exists
    if [ -d "$SOURCE_DIR" ]; then
        # Copy all files from the source directory to the target directory
        sudo cp -r $SOURCE_DIR/* $TARGET_DIR
        echo "HTML files have been copied to $TARGET_DIR."
    else
        echo "Source directory $SOURCE_DIR does not exist."
    fi
}

main
