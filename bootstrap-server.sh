#!/bin/bash

# CONSTANTS
USERNAME=$1
FIRST_NAME=$2
LAST_NAME=$3
EMAIL=$4
PASSWORD=$5
SHORTNAME=$6
LONGNAME=$7
COOKBOOK_PATH=$8

# Wait chef service is ready
until (curl -D - http://localhost:8000/_status) | grep "200 OK"; do sleep 40s; done

# Setup chef server user and organization
chef-server-ctl user-create $USERNAME $FIRST_NAME $LAST_NAME $EMAIL $PASSWORD -f /home/vagrant/pem/$USERNAME.pem
chef-server-ctl org-create $SHORTNAME $LONGNAME --association_user $USERNAME -f /home/vagrant/pem/$SHORTNAME-validator.pem

# Backup pre-existing knife configuration file
if [ -f /home/vagrant/pem/knife.rb ]; then
	dt=`date '+%Y%m%d-%H%M%S'`
	mv /home/vagrant/pem/knife.rb /home/vagrant/pem/knife-$dt.rb
fi

# Create knife configuration file
cat <<EOT >> /home/vagrant/pem/knife.rb
current_dir =            File.dirname(__FILE__)
log_level                :info
log_location             '/var/log/chef/chef.log'
node_name                "$USERNAME"
client_key               "#{current_dir}/$USERNAME.pem"
validation_client_name   '$SHORTNAME'
validation_key           "#{current_dir}/$SHORTNAME-validator.pem"
chef_server_url          'https://chef.vmhost.psu.test/organizations/$SHORTNAME'
syntax_check_cache_path  "#{ENV['HOME']}/.chef/syntaxcache"
cookbook_path            ['$COOKBOOK_PATH']
ssl_verify_mode          :verify_none
verify_api_cert          false
EOT
