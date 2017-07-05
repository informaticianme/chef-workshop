#encoding: utf-8
# -*- mode: ruby -*-
# vi: set ft=ruby :

# CONSTANTS
USERNAME='pke3'
FIRST_NAME='Kieran'
LAST_NAME='Etienne'
EMAIL='pke3@psu.edu'
PASSWORD='blatherskite'
USERHOME="/home/#{USERNAME}"
SHORTNAME="psu-stewardship"
LONGNAME="'Penn State University Libraries'"
KEY_LOCATION="/home/#{USERNAME}/.ssh"
KEY_FILENAME='ext.domain@user'
COOKBOOK_PATH="#{USERHOME}/Projects/informaticianme/chef.cookbooks"

# ENVIRONMENT VARIABLES
HOME=ENV['HOME']

# VIRTUAL MACHINES
machines = [
	{ :name => 'chef',       :subd => 'vmhost',    :ip => '172.128.28.11', :ram => '4096', :cpus => '2' }
	#{ :name => 'isolon',     :subd => 'vmhost',    :ip => '172.128.28.21', :ram => '512',  :cpus => '1' }
	#{ :name => 'mysqlc',     :subd => 'vmhost',    :ip => '172.128.28.22', :ram => '512',  :cpus => '1' },
	#{ :name => 'sswebprod',  :subd => 'libraries', :ip => '172.128.28.31', :ram => '512',  :cpus => '1' },
	#{ :name => 'ssjobsprod', :subd => 'libraries', :ip => '172.128.28.32', :ram => '512',  :cpus => '1' },
	#{ :name => 'ssrepoprod', :subd => 'libraries', :ip => '172.128.28.33', :ram => '512',  :cpus => '1' },
	#{ :name => 'sswebtest',  :subd => 'libraries', :ip => '172.128.28.34', :ram => '512',  :cpus => '1' },
	#{ :name => 'ssjobstest', :subd => 'libraries', :ip => '172.128.28.35', :ram => '512',  :cpus => '1' },
	#{ :name => 'ssrepotest', :subd => 'libraries', :ip => '172.128.28.36', :ram => '512',  :cpus => '1' },
]

Vagrant.configure('2') do |config|
	config.hostmanager.enabled = true
	config.hostmanager.manage_host = true
	config.hostmanager.manage_guest = true
	config.hostmanager.ignore_private_ip = false
	config.hostmanager.include_offline = true

	machines.each do |machine|
		is_chef = machine[:name] == 'chef'
		is_automate = machine[:name] == 'automate'

		config.vm.define machine[:name] do |node|
			node.vm.box = 'centos/7'
			node.vm.box_check_update
			node.vm.hostname = "#{machine[:name]}.#{machine[:subd]}.psu.test"
			node.vm.network :private_network, ip: "#{machine[:ip]}"
			node.vm.provider :virtualbox do |vb|
				vb.name = "#{machine[:name]}"
				vb.memory = "#{machine[:ram]}"
				vb.cpus = "#{machine[:cpus]}"
				vb.customize ['modifyvm', :id, '--vram', '33']
			end

			node.vm.provision :file,
				:source => "#{KEY_LOCATION}/#{KEY_FILENAME}",
				:destination => "/home/vagrant/#{KEY_FILENAME}"
			node.vm.provision :file,
				:source => "#{KEY_LOCATION}/#{KEY_FILENAME}.pub",
				:destination => "/home/vagrant/#{KEY_FILENAME}.pub"
			node.vm.provision :shell,
				:path => "bootstrap-guest.sh",
				:args => [
					"#{USERNAME}",
					"#{PASSWORD}",
					"#{USERHOME}",
					"#{KEY_LOCATION}",
					"#{KEY_FILENAME}"
				]

			if is_chef
				node.vm.synced_folder "#{HOME}/.chef", "/home/vagrant/pem"
				node.vm.provision :shell,
					:path => "bootstrap-server.sh",
					:args => [
						"#{USERNAME}",
						"#{FIRST_NAME}",
						"#{LAST_NAME}",
						"#{EMAIL}",
						"#{PASSWORD}",
						"#{SHORTNAME}",
						"#{LONGNAME}",
						"#{machine[:name]}",
						"#{COOKBOOK_PATH}"
					]
			end

			if !is_chef
				node.vm.provision :file,
					:source => "#{HOME}/.chef/#{SHORTNAME}-validator.pem",
					:destination => "/home/vagrant/#{SHORTNAME}-validator.pem"
				node.vm.provision :shell,
					:path => "bootstrap-node.sh",
					:args => [
						"#{USERNAME}",
						"#{machine[:name]}",
						"#{SHORTNAME}",
						"#{CHEF_INTERVAL}"
					]
			end

		end
	end
end
