#!/bin/bash

# CONSTANTS
USERNAME=$1
PASSWORD=$2
USERHOME=$3
KEY_LOCATION=$4
KEY_FILENAME=$5

# Set & Configure Remote User
adduser $USERNAME
echo $PASSWORD | passwd $USERNAME --stdin
usermod -aG wheel $USERNAME

# Place User SSH Keys
sudo mkdir -p "$KEY_LOCATION"
sudo mv /home/vagrant/$KEY_FILENAME $KEY_LOCATION
sudo mv /home/vagrant/$KEY_FILENAME.pub $KEY_LOCATION
sudo cp $KEY_LOCATION/$KEY_FILENAME.pub $KEY_LOCATION/authorized_keys
sudo chown -R $USERNAME:$USERNAME $KEY_LOCATION
sudo chmod 0600 $KEY_LOCATION/$KEY_FILENAME
sudo chmod 0644 $KEY_LOCATION/$KEY_FILENAME.pub

# Add ssh keys to keychain
sudo echo "eval \`keychain --eval --agents ssh $KEY_LOCATION/$KEY_FILENAME\`" >> "$USERHOME/.bash_profile"

# Install keychain for ssh keys
sudo rpm -Uvh https://s3-eu-west-1.amazonaws.com/rpm-repos-el7/rpm-repos-el7-1-1.el7.noarch.rpm
sudo yum install -y keychain

# Disable firewall
sudo systemctl stop firewalld

# Set SELinux to permissive
sudo setenforce permissive
sudo sed -i -e 's/enforcing/permissive/g' /etc/selinux/config
