# encoding: utf-8
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
COOKBOOK_PATH="#{USERHOME}/Projects/github.com/informaticianme/chef.cookbooks"

# ENVIRONMENT VARIABLES
HOME=ENV['HOME']

# VIRTUAL MACHINES
machines = [
	 { :name => 'chef',       :ssh_port => '2511', :subd => 'vmhost',    :ip => '174.128.28.11', :ram => '4096', :cpus => '2' },
	 { :name => 'isilon',     :ssh_port => '2521', :subd => 'vmhost',    :ip => '174.128.28.21', :ram => '512',  :cpus => '1' },
	 { :name => 'mariaprod',  :ssh_port => '2522', :subd => 'vmhost',    :ip => '172.128.28.22', :ram => '512',  :cpus => '1' },
	#{ :name => 'mariatest',  :ssh_port => '2523', :subd => 'vmhost',    :ip => '172.128.28.23', :ram => '512',  :cpus => '1' },
	 { :name => 'ssprodweb',  :ssh_port => '2531', :subd => 'libraries', :ip => '172.128.28.31', :ram => '512',  :cpus => '1' },
	#{ :name => 'ssprodjobs', :ssh_port => '2532', :subd => 'libraries', :ip => '172.128.28.32', :ram => '512',  :cpus => '1' },
	#{ :name => 'ssprodrepo', :ssh_port => '2533', :subd => 'libraries', :ip => '172.128.28.33', :ram => '512',  :cpus => '1' },
	 { :name => 'sstestweb',  :ssh_port => '2534', :subd => 'libraries', :ip => '172.128.28.34', :ram => '512',  :cpus => '1' }
	#{ :name => 'sstestjobs', :ssh_port => '2535', :subd => 'libraries', :ip => '172.128.28.35', :ram => '512',  :cpus => '1' },
	#{ :name => 'sstestrepo', :ssh_port => '2536', :subd => 'libraries', :ip => '172.128.28.36', :ram => '512',  :cpus => '1' }
]

Vagrant.configure('2') do |config|
	config.hostmanager.enabled = true
	config.hostmanager.manage_host = true
	config.hostmanager.manage_guest = true
	config.hostmanager.ignore_private_ip = false
	config.hostmanager.include_offline = true

	machines.each do |machine|
		is_chef = machine[:name] == 'chef'

		config.vm.define machine[:name] do |node|
			node.vm.box = 'centos/7'
			node.vm.box_check_update
			node.vm.hostname = "#{machine[:name]}.#{machine[:subd]}.psu.test"
			node.vm.network :private_network, ip: "#{machine[:ip]}"
			node.vm.network :forwarded_port, guest: 22, host: machine[:ssh_port]
			node.vm.provider :virtualbox do |vb|
				vb.name = "#{machine[:name]}"
				vb.memory = "#{machine[:ram]}"
				vb.cpus = "#{machine[:cpus]}"
				vb.customize ['modifyvm', :id, '--vram', '33']
			end
			node.vm.provision :file,
				:source => "#{KEY_LOCATION}/#{KEY_FILENAME}.pem",
				:destination => "/home/vagrant/#{KEY_FILENAME}.pem"
			node.vm.provision :file,
				:source => "#{KEY_LOCATION}/#{KEY_FILENAME}.pub",
				:destination => "/home/vagrant/#{KEY_FILENAME}.pub"
			node.vm.provision :shell,
				:path => "bootstrap-guest.sh",
				:args => [
					"#{machine[:name]}",
					"#{USERNAME}",
					"#{PASSWORD}",
					"#{USERHOME}",
					"#{KEY_LOCATION}",
					"#{KEY_FILENAME}"
				]

			if is_chef
				node.vm.synced_folder "#{HOME}/.chef", "/home/vagrant/pem"
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
						"#{SHORTNAME}",
						"#{LONGNAME}",
						"#{COOKBOOK_PATH}"
					]
			end

			if !is_chef
				node.vm.provision :file,
					:source => "#{HOME}/.chef/#{SHORTNAME}-validator.pem",
					:destination => "/home/vagrant/#{SHORTNAME}-validator.pem"
				node.vm.provision :chef_solo do |chef|
					chef.run_list = ['recipe[chef-client]']
				end
				node.vm.provision :shell,
					:path => "bootstrap-node.sh",
					:args => [
						"#{USERNAME}",
						"#{machine[:name]}",
						"#{SHORTNAME}"
					]
			end
		end
	end
end
