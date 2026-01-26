#!/bin/bash

rm ~/.ssh/id_rsa ~/.ssh/id_rsa.pub
touch ~/.ssh/id_rsa
touch ~/.ssh/id_rsa.pub
chmod 600 /home/ubuntu/.ssh/id_rsa
chmod 600 /home/ubuntu/.ssh/id_rsa.pub
vim ~/.ssh/id_rsa
# Add your SSH private key content above and save the file

vim ~/.ssh/id_rsa.pub
# Add your SSH public key content above and save the file
ssh -T git@github.com -o StrictHostKeyChecking=no
# You should see "Hi <username>! You've successfully authenticated, but GitHub does not provide shell access."

# Set Up Application Environment
git clone git@github.com:judestp/jtb-monorepo.git
cd jtb-monorepo
sudo apt install -y make
make clone
sudo apt update && sudo apt install -y zip unzip
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"
sdk install java 17.0.0-tem
sdk default java 17.0.0-tem
sdk install maven 3.9.9
sdk default maven 3.9.9
java --version
mvn --version
make install
make dev