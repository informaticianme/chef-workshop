#!/bin/bash
# Install prerequistes for working with Chef
# Do not run as sudo
# $ ./chef-bootstrap.sh  >> chef-bootstrap.log 2>&1 # Apt causes scripting issues.

# Set Constants
NAME='First, Initial, Last'
EMAIL='user@domain.ext'
SSHKEY='ext.domain@user'

# Install 'lsb_release'
if [ -x "$(command -v dnf)" ]; then
	sudo dnf install -y redhat-lsb-core
elif [ -x "$(command -v yum)" ]; then
	sudo yum install -y redhat-lsb-core
elif [ -x "$(command -v apt)" ]; then
	sudo apt install -y lsb_release
else
	echo 'Unsupported Operating System, aborting...'
	exit 1
fi

# Determine operating system
distributor="$(lsb_release -i)"
os=${distributor:16}

update_operating_system() {
	case $os in
		Fedora)
			sudo dnf update -y
			;;
		Ubuntu)
			sudo apt update -y
			sudo apt upgrade -y
			;;
	esac
}

install_vim() {
	case $os in
		Fedora)
			sudo dnf install -y vim
			;;
		Ubuntu)
			sudo apt install -y vim
			;;
	esac
}

install_keychain() {
	case $os in
		Fedora)
			sudo dnf install -y keychain 
			;;
		Ubuntu)
			sudo apt install -y keychain
			;;
	esac
}

install_git() {
	case $os in
		Fedora)
			sudo dnf install -y git 
			;;
		Ubuntu)
			sudo add-apt-repository ppa:git-core/ppa
			sudo apt update
			sudo apt install -y git
			;;
	esac
	git config --global user.email "$NAME"
	git config --global user.name "$EMAIL"
}

create_ssh_key() {
	ssh-keygen -t rsa -C $EMAIL -f $HOME/.ssh/$SSHKEY
}

configure_keychain() {
	sudo echo "eval `keychain --eval --agents ssh $SSHKEY`" >> $HOME/.bashrc
}

install_virtualbox() {
	case $os in
		Fedora)
			sudo dnf install -y VirtualBox
			;;
		Ubuntu)
			sudo apt-add-repository "deb http://download.virtualbox.org/virtualbox/debian $(lsb_release -sc) contrib"
			wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -
			sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys A2F683C52980AECF
			sudo apt update
			sudo apt install -y virtualbox
			;;
	esac
}

install_vagrant() {
	case $os in
		Fedora)
			wget https://releases.hashicorp.com/vagrant/2.0.1/vagrant_2.0.1_x86_64.rpm
			sudo dnf install -y vagrant
			rm vagrant_2.0.1_x86_64.rpm
			;;
		Ubuntu)
			wget https://releases.hashicorp.com/vagrant/2.0.1/vagrant_2.0.1_x86_64.deb
			sudo dpkg -i vagrant_2.0.1_x86_64.deb
			rm vagrant_2.0.1_x86_64.deb
			;;
	esac
	vagrant plugin install vagrant-vbguest
	vagrant plugin install vagrant-berkshelf
	#vagrant plugin install landrush
	vagrant plugin install vagrant-hostmanager
}

configure_hostmanager() {
	# add the following lines to /etc/sudoers.d/vagrant_hostmanager
	# https://github.com/devopsgroup-io/vagrant-hostmanager
	#Cmnd_Alias VAGRANT_HOSTMANAGER_UPDATE = /bin/cp ~/.vagrant.d/tmp/hosts.local /etc/hosts
	#%wheel ALL=(root) NOPASSWD: VAGRANT_HOSTMANAGER_UPDATE
	# add user to admin group
	# gpasswd wheel -a $(whoami)
	echo ''
}

install_chefdk() {
	sudo curl https://omnitruck.chef.io/install.sh | sudo bash -s -- -P chefdk -c stable
}

configure_chefdk() {
	# If your workstation will primarily be used to manage Chef for your infrastructure, you will likely want to default to the version of Ruby installed with Chef. You can do this by modifying your .bash_profile so that Chef's Ruby takes precedence:
	# echo 'eval "$(chef shell-init bash)"' >> ~/.bash_profile
	# source ~/.bash_profile
	if ! [ -d "/var/log/chef" ]; then
		sudo mkdir /var/log/chef
	fi
	sudo chown $USERNAME:$USERNAME /var/log/chef
}

run() {
	update_operating_system
	install_vim
	install_keychain
	install_git
	create_ssh_key
	configure_keychain
	install_virtualbox
	install_vagrant
	configure_hostmanager
	install_chefdk
	configure_chefdk
}

run
