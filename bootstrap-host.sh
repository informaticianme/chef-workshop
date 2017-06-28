#!/bin/bash
# Install prerequistes for working with Chef
# Do not run as sudo
# $ ./chef-bootstrap.sh  >> chef-bootstrap.log 2>&1 # Apt causes scripting issues.

# Set Constants
NAME='First, Initial, Last'
EMAIL='user@domain.ext'
SSHKEY='ext.domain@user'

# Update and Upgrade base installation
sudo apt update -y
sudo apt upgrade -y

# Ensure proper package channels are available
# - [ ] Need to download keychain from universe channel for example

# Install Vi Improved from Ubuntu channel
sudo apt update

# Install Git from official PPA
sudo add-apt-repository ppa:git-core/ppa
sudo apt update
sudo apt install -y git
git config --global user.email "$NAME"
git config --global user.name "$EMAIL"

# Create New SSH key
ssh-keygen -t rsa -C $EMAIL -f $HOME/.ssh/$SSHKEY

# Install Keychain for ssh keys
sudo apt install keychain -y
sudo echo "eval `keychain --eval --agents ssh $SSHKEY`" >> $HOME/.bashrc

# Install VirtualBox through Offical Oracle source
# http://www.ubuntubuzz.com/2016/04/how-to-install-virtualbox-from-ppa-in.html
# https://askubuntu.com/questions/367248/how-to-install-virtualbox-from-command-line
sudo apt-add-repository "deb http://download.virtualbox.org/virtualbox/debian $(lsb_release -sc) contrib"
wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys A2F683C52980AECF
sudo apt update
sudo apt install -y virtualbox

# Install Vagrant from official deb package
wget https://releases.hashicorp.com/vagrant/1.9.5/vagrant_1.9.5_x86_64.deb
sudo dpkg -i vagrant_1.9.5_x86_64.deb
rm vagrant_1.9.5_x86_64.deb
vagrant plugin install vagrant-vbguest
vagrant plugin install vagrant-berkshelf
#vagrant plugin install landrush
vagrant plugin install vagrant-hostmanager

# add the following lines to /etc/sudoers.d/vagrant_hostmanager
# https://github.com/devopsgroup-io/vagrant-hostmanager
Cmnd_Alias VAGRANT_HOSTMANAGER_UPDATE = /bin/cp <home-directory>/.vagrant.d/tmp/hosts.local /etc/hosts
%<admin-group> ALL=(root) NOPASSWD: VAGRANT_HOSTMANAGER_UPDATE

# Install latest version of Chefdk (omnibus method)
sudo curl https://omnitruck.chef.io/install.sh | sudo bash -s -- -P chefdk -c stable

# If your workstation will primarily be used to manage Chef for your infrastructure, you will likely want to default to the version of Ruby installed with Chef. You can do this by modifying your .bash_profile so that Chef's Ruby takes precedence:
# echo 'eval "$(chef shell-init bash)"' >> ~/.bash_profile
# source ~/.bash_profile

# Setup log directory for chef / knife
sudo mkdir /var/log/chef
chown $USERNAME:$USERNAME /var/log/chef
