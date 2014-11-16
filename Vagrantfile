# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    # box with os - Official Ubuntu Server 14.04 LTS (Trusty Tahr) builds
    config.vm.box = "ubuntu/trusty64"

    # network config - port forwarding
    config.vm.network :forwarded_port, guest: 80, host: 8931, auto_correct: true

    # sync root folder with /var/www in box
    config.vm.synced_folder "./", "/var/www", create: true, group: "www-data", owner: "www-data"

    # script to install packages and configure box
    config.vm.provision "shell" do |s|
        s.path = "provision/setup.sh"
    end

    # configure virtualbox
    config.vm.provider "virtualbox" do |v|
        v.name = "SitePoint Test Vagrant"
        v.customize ["modifyvm", :id, "--memory", "1024"]
    end
end
