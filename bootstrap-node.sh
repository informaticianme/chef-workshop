#!/bin/bash

# CONSTANTS	
USERNAME=$1
MACHINE_NAME=$2
SHORTNAME=$3
CHEF_INTERVAL=$4

# Create some necessary directories
sudo /bin/mkdir -p /etc/chef
sudo /bin/mkdir -p /var/chef
sudo /bin/mkdir -p /var/lib/chef
sudo /bin/mkdir -p /var/log/chef

# Copy in the validiator file
sudo cp /home/vagrant/$SHORTNAME-validator.pem /etc/chef/$SHORTNAME-validator.pem

# Provide USER authorization to chef related areas
sudo chown -R $USERNAME:$USERNAME /etc/chef
sudo chown -R $USERNAME:$USERNAME /var/chef
sudo chown -R $USERNAME:$USERNAME /var/lib/chef
sudo chown -R $USERNAME:$USERNAME /var/log/chef

cd /etc/chef/

# Install chef
curl -L https://omnitruck.chef.io/install.sh | bash || error_exit 'could not install chef'

# Generate node name
NODENAME="$MACHINE_NAME-$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 4 | head -n 1)"

# Create client.rb
if [ -f /etc/chef/client.rb ]; then
	dt=`date '+%Y%m%d-%H%M%S'`
	mv /etc/chef/client.rb /etc/chef/client-$dt.rb
fi

cat <<EOT >> /etc/chef/client.rb
log_level	:info
log_location	"/var/log/chef/chef.log"
chef_server_url	'https://chef.vmhost.psu.test/organizations/$SHORTNAME'
validation_client_name '$SHORTNAME-validator'
validation_key '/etc/chef/$SHORTNAME-validator.pem'
ssl_verify_mode :verify_none
verify_api_cert false
EOT

# Register node with server
chef-client -u $USERNAME -N $NODENAME
