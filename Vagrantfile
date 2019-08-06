# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.

Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  config.vm.define "oci" do |oci|
    # Every Vagrant development environment requires a box. You can search for
    # boxes at https://vagrantcloud.com/search.
    oci.vm.box = "roboxes/oracle7"
    oci.vm.hostname = "oci"

    oci.vm.provision "packages", type: "shell", path: "./provisioners/oci/install_packages.sh"
    oci.vm.provision "packer", type: "shell", path: "./provisioners/oci/install_packer.sh"
    oci.vm.provision "ansible_modules", type: "shell", path: "./provisioners/oci/install_ansible_modules.sh"
    oci.vm.provision "files", type: "file", source: "./provisioners/oci/files", destination: "$HOME"
  end 

  config.vm.define "mysql" do |mysql|
    # Every Vagrant development environment requires a box. You can search for
    # boxes at https://vagrantcloud.com/search.
    mysql.vm.box = "roboxes/oracle7"
    mysql.vm.hostname = "mysql"

    mysql.vm.provision "packages", type: "shell", path: "./provisioners/mysql/install_packages.sh"
    mysql.vm.provision "mysql", type: "shell", path: "./provisioners/mysql/install_mysql.sh"
    mysql.vm.provision "mysql_support_files", type: "file", source: "./MySQL_Support_Exercise", destination: "$HOME"
    mysql.vm.provision "extract_mysql_support_files", type: "shell", path: "./provisioners/mysql/extract_mysql_support_files.sh"

    mysql.vm.network "forwarded_port", guest: 3306, host: 3306
  end 

end
