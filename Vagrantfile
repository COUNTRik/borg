# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "centos/7"

#  config.vm.provision "ansible" do |ansible|
#    ansible.verbose = "vvv"
#    ansible.playbook = "playbook.yml"
#    ansible.become = "true"
#  end

  config.vm.provider "virtualbox" do |v|
    v.memory = 1024
    v.cpus = 1
  end

  config.vm.define "backup" do |backup|
    # backup.vm.network "private_network", ip: "192.168.50.10", virtualbox__intnet: "net1"
    backup.vm.hostname = "backup"
    backup.vm.provision "shell", path: "scripts/backup.sh"
  end

  config.vm.define "client" do |client|
    # client.vm.network "private_network", ip: "192.168.50.11", virtualbox__intnet: "net1"
    client.vm.hostname = "client"
    client.vm.provision "shell", path: "scripts/client.sh"
  end

end