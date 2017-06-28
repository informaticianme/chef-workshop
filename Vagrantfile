# -*- mode: ruby -*-
# vi: set ft=ruby :

# CONSTANTS
USERNAME='pke3'
FIRST_NAME='Kieran'
LAST_NAME='Etienne'
EMAIL='pke3@psu.edu'
PASSWORD='blatherskite'
USERHOME="/home/#{USERNAME}"
SHORT_NAME="psu-stewardship"
LONG_NAME="'Penn State University Libraries'"
KEY_LOCATION="/home/#{USERNAME}/.ssh"
KEY_FILENAME='ext.domain@user'
COOKBOOK_PATH="#{USERHOME}/Projects/informaticianme/chef.cookbooks"
CHEF_INTERVAL="1800"

# ENVIRONMENT VARIABLES
HOME=ENV['HOME']

# VIRTUAL MACHINES
machines = [
	{ :name => 'chef',       :subd => 'vmhost',    :ip => '172.128.28.11', :ram => '8192', :cpus => '4' },
	{ :name => 'isolon',     :subd => 'vmhost',    :ip => '172.128.28.12', :ram => '512', :cpus => '1' }
	#{ :name => 'mysqlc',     :subd => 'vmhost',    :ip => '172.128.28.13', :ram => '512', :cpus => '1' },
	#{ :name => 'sswebprod',  :subd => 'libraries', :ip => '172.128.28.21', :ram => '512', :cpus => '1' },
	#{ :name => 'ssjobsprod', :subd => 'libraries', :ip => '172.128.28.22', :ram => '512', :cpus => '1' },
	#{ :name => 'ssrepoprod', :subd => 'libraries', :ip => '172.128.28.23', :ram => '512', :cpus => '1' },
	#{ :name => 'sswebtest',  :subd => 'libraries', :ip => '172.128.28.24', :ram => '512', :cpus => '1' },
	#{ :name => 'ssjobstest', :subd => 'libraries', :ip => '172.128.28.25', :ram => '512', :cpus => '1' },
	#{ :name => 'ssrepotest', :subd => 'libraries', :ip => '172.128.28.26', :ram => '512', :cpus => '1' },
]

Vagrant.configure('2') do |config|
	config.hostmanager.enabled = true
	config.hostmanager.manage_host = true
	config.hostmanager.manage_guest = true
	config.hostmanager.ignore_private_ip = false
	config.hostmanager.include_offline = true

	# Find some way to disable downloading of GuestAdditions iso!

	machines.each do |machine|
		is_chef = machine[:name] == 'chef'

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

			if is_chef
				node.berkshelf.enabled = true
				node.berkshelf.berksfile_path = 'Berksfile'
				node.vm.synced_folder "#{HOME}/.chef", "/home/vagrant/pem"
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
				node.vm.provision :chef_solo do |chef|
					chef.run_list = ['recipe[chef-server]']
				end
				node.vm.provision :shell,
					:path => "bootstrap-server.sh",
					:args => [
						"#{USERNAME}",
						"#{FIRST_NAME}",
						"#{LAST_NAME}",
						"#{EMAIL}",
						"#{PASSWORD}",
						"#{SHORT_NAME}",
						"#{LONG_NAME}",
						"#{COOKBOOK_PATH}"
					]
			end

			if !is_chef
				node.vm.provision :shell,
					:path => "bootstrap-node.sh",
					:args => [
						"#{USERNAME}",
						"#{CHEF_INTERVAL}",
						"#{machine[:name]}"
					]
				node.vm.provision :file,
					:source => "#{HOME}/.chef/#{USERNAME}.pem",
					:destination => "/etc/chef/#{USERNAME}.pem"
				node.vm.provision :file,
					:source => "#{HOME}/.chef/#{SHORT_NAME}.pem",
					:destination => "/etc/chef/#{SHORT_NAME}.pem"
				node.vm.provision :shell,
					:inline => "sudo chown -R #{USERNAME}:#{USERNAME} /etc/chef"
			end

		end
	end
end
