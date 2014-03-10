# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  
  config.vm.box = "precise64"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"

  # config for the maze box
  config.vm.define :mazeserver do |app|
  # app.vm.synced_folder ".", "/vagrant", :nfs => true
    app.vm.network :private_network, ip: "10.33.33.10"
    app.vm.hostname = "maze.local"
    app.vm.provider :virtualbox do |vb|
        vb.customize ["modifyvm", :id, "--cpus", 2]
        vb.customize ["modifyvm", :id, "--memory", 1024]
    end
    app.vm.provision :puppet do |puppet|
      puppet.manifests_path = "puppet/manifests"
      puppet.manifest_file = "maze.pp"
      puppet.module_path    = "puppet/modules"
      puppet.options = [
#        '--verbose',
#        '--debug',
      ]
    end
  end
 
  # config for the node1 box
  config.vm.define :node1 do |node1|
    node1.vm.network :private_network, ip: "10.33.33.11"
    node1.vm.hostname = "node1.local"
    node1.vm.provider :virtualbox do |vb|
        vb.customize ["modifyvm", :id, "--cpus", 1]
        vb.customize ["modifyvm", :id, "--memory", 384]
    end
    node1.vm.provision :puppet do |puppet|
      puppet.manifests_path = "puppet/manifests"
      puppet.manifest_file = "node1.pp"
      puppet.module_path    = "puppet/modules"
      puppet.options = [
#        '--verbose',
#        '--debug',
      ]
    end
  end
  
  # config for the node2 box
  config.vm.define :node2 do |node2|
    node2.vm.network :private_network, ip: "10.33.33.12"
    node2.vm.hostname = "node2.local"
    node2.vm.provider :virtualbox do |vb|
        vb.customize ["modifyvm", :id, "--cpus", 1]
        vb.customize ["modifyvm", :id, "--memory", 384]
    end
    node2.vm.provision :puppet do |puppet|
      puppet.manifests_path = "puppet/manifests"
      puppet.manifest_file = "node2.pp"
      puppet.module_path    = "puppet/modules"
      puppet.options = [
#        '--verbose',
#        '--debug',
      ]
    end
  end

end
