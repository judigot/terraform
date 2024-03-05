#!/bin/bash

mkdir app

cd app

sudo chmod -R 777 ~/app

ssh-keygen -t rsa -f ~/.ssh/id_rsa -P "" && clear && echo -e "Copy and paste the public key below to your GitHub account:\n\n\e[32m$(cat ~/.ssh/id_rsa.pub) \e[0m\n" # Green

# *add domain name to sodatech_app/config/environments/development.rb
# Rails.application.config.hosts << "judigot.com"
# Rails.application.config.hosts << "judigot.com:3000"