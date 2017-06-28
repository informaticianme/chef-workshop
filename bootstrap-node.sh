#!/bin/bash

# CONSTANTS	
USERNAME=$1
CHEF_INTERVAL=$2
MACHINE_NAME=$3

# Do some chef pre-work
sudo /bin/mkdir -p /etc/chef
sudo /bin/mkdir -p /var/lib/chef
sudo /bin/mkdir -p /var/log/chef
sudo chown -R vagrant:vagrant /etc/chef
sudo chown -R $USERNAME:$USERNAME /var/lib/chef
sudo chown -R $USERNAME:$USERNAME /var/log/chef

cd /etc/chef/

# Install chef
curl -L https://omnitruck.chef.io/install.sh | bash || error_exit 'could not install chef'

# Generate node name
#NODE_NAME="$HOSTNAME-$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 4 | head -n 1)"
NODE_NAME="$MACHINE_NAME-$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 4 | head -n 1)"

# Create client.rb
cat <<EOT >> /etc/chef/client.rb
log_level	:info
log_location	"/var/log/chef/chef.log"
chef_server_url	'https://chef.vmhost.psu.test/organizations/psu-stewardship'
client_key '/etc/chef/pke3.pem'
validation_client_name 'psu-stewardship-validator'
validation_key '/etc/chef/psu-stewardship.pem'
node_name '$NODE_NAME'
ssl_verify_mode :verify_none
verify_api_cert false
EOT

# Register node with server and set interval
# sudo chef-client -i $CHEF_INTERVAL
