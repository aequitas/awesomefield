# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.hostname = "awesomnia.awesomeretro.dev"
  config.landrush.enabled = true
  config.landrush.tld = 'awesomeretro.dev'

  config.vm.box = "ubuntu/trusty64"

  config.vm.network "private_network", type: "dhcp"

  config.vm.provider "virtualbox" do |v|
    v.customize ["modifyvm", :id, "--nictype1", "virtio"]
    # v.customize ["modifyvm", :id, "--nictype2", "virtio"]
  end

  config.vm.post_up_message = "
    Host is now accessable at: http://awesomnia.awesomeretro.dev

    Subdomains are available at: http://{subdomain}.awesomnia.awesomeretro.dev
    Eg: http://lists.awesomeretro.org is available at: http://lists.awesomnia.awesomeretro.dev
  "

  config.vm.provision "shell", keep_color: true, path: "scripts/bootstrap.sh"

  config.vm.provision "puppet" do |puppet|
    puppet.manifests_path = "manifests"
    puppet.manifest_file = "site.pp"

    puppet.module_path = ["modules", "vendor/modules"]

    puppet.hiera_config_path = "hiera.yaml"
    puppet.working_directory = "/vagrant"

    # puppet.options = "--verbose"
  end
end
