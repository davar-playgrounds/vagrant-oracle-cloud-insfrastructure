# Vagrant to provision and configure resources on Oracle Cloud Infrastructure

- Run a [Vagrant](http://vagrantup.com) machine that runs Oracle Linux and can be used to provision and configure resources on [Oracle Cloud Infrastructure](https://cloud.oracle.com/iaas) using [the OCI CLI](https://docs.cloud.oracle.com/iaas/Content/API/Concepts/cliconcepts.htm), [Terraform](http://terraform.io), and [Ansible](http://ansible.com). 
- **Optionally, also run a Vagrant machine that runs Oracle Linux, MySQL 5.7, the Java JDK, and gdb.**

## Acknowledgements 

Thank you to:

- [@jamalarif](https://github.com/jamalarif) for [Oracle Cloud Infrastructure Automation with Terraform](https://medium.com/@j.jamalarif/oracle-cloud-infrastructure-automation-with-terraform-f920df259504)
- The Oracle community at large for 
    - [How to use Terraform with Oracle Linux and Oracle Cloud Infrastructure (OCI)](https://community.oracle.com/docs/DOC-1019936) 
    - [Install Python SDK and CLI for Oracle Cloud Infrastructure on Oracle Linux](https://blogs.oracle.com/linux/installing-python-sdk-and-cli-for-oracle-cloud-infrastructure-on-oracle-linux:-a-tutorial)
    - [Getting Started with Ansible for Oracle Cloud Infrastructure](https://docs.cloud.oracle.com/iaas/Content/API/SDKDocs/ansiblegetstarted.htm)
- Rich Jenks for [Vagrant and MySQL Workbench](https://richjenks.com/vagrant-and-mysql-workbench/)

## Run a Vagrant machine that can be used to provision and configure resources on Oracle Cloud Infrastructure 

Run a Vagrant machine that runs Oracle Linux and can be used to provision and configure resources on [Oracle Cloud Infrastructure](https://cloud.oracle.com/iaas) via [the OCI CLI](https://docs.cloud.oracle.com/iaas/Content/API/Concepts/cliconcepts.htm), [Packer](https://packer.io), [Terraform](https://terraform.io), and [Ansible](https://www.ansible.com).  Access it via the command line from the Vagrant host (your computer).

1. [Get Started with Oracle Cloud Platform for Free](https://cloud.oracle.com/tryit), if you haven't already.
1. Download and install [Vagrant](http://vagrantup.com). 
1. At the command line, using a Bash shell, clone this repo: run `git clone https://github.com/gordonIanJ/vagrant-oracle-cloud-infrastructure.git` .
1. Change to the resultant directory: run `cd vagrant-oracle-cloud-infrastructure` .
1. Run the Vagrant machine named "oci": run `vagrant up oci` . 
1. Visit the OCI web console. There, navigate to Menu > Identity > Compartments. View and take note of the Compartment OCID.
1. Navigate to Menu > Administration > Tenancy Details. Take note of the Tenancy OCID.
1. Near top-right, click the "user/profile" icon and then select User Settings. Take note of the User OCID. 
1. At top-right, take note of the OCI region. It'll be something shaped like us-phoenix-1.
1. Log in to the vagrant machine: run `vagrant ssh oci` to . The shell prompt will change to be like `[vagrant@oci ~]$` , indicating you're "sitting" on the vagrant machine named "oci". 
1. Set up keys and secrets for OCI CLI: run `make oci` . You'll be prompted for the OCI Compartment OCID, the OCI Region, the OCI Tenancy OCID, and the OCI User OCID. Supply each in turn.
1. Watch the output to see the API Public Key and the API Key Fingerprint. Copy the API Public Key to the clipboard, and note the API Key Fingerprint. 
1. Follow the instructions in [How to Upload the Public Key to OCI](https://docs.cloud.oracle.com/Content/API/Concepts/apisigningkey.htm#How2).
1. A fingerprint will be displayed at the OCI web console when the upload completes, compare it with the fingerprint from the output of `make oci` . The two should match!
1. Try Terraform. Ensure it can access OCI.
    1. Change to the terraform/ directory: run `cd terraform/` .
    1. Initialize terraform: run `terraform init` . Expect the result to include "Terraform has been successfully initialized!"
    1. Run `terraform plan` . Expect the result to include "No changes. Infrastructure is up-to-date."
    1. Learn more about Terraform for OCI:
        1. [Learn about provisioning infrastructure with HashiCorp Terraform](https://learn.hashicorp.com/terraform/)
        1. [Oracle Cloud Infrastructure Provider](https://www.terraform.io/docs/providers/oci/index.html)
1. Try the OCI CLI: use it to get the namespace of your OCI tenancy. 
    1. Change to the home directory: run `cd ~/` . 
        1. Run `oci os ns get` . 
        1. Expect the contents of the following code block as a result.

        ```
        {
            "data": "<the namespace of your OCI tenancy>"
        }
        ``` 
        
        1. Copy the namespace of your OCI tenancy (the value from within the double quotes of the part on the right of the result).
    1. Learn more about the OCI CLI: [Getting Started with the Command Line Interface](https://docs.cloud.oracle.com/iaas/Content/GSG/Tasks/gettingstartedwiththeCLI.htm)
1. Try Ansible: use it to fetch all of the facts pertaining to all of the buckets in your OCI compartment, if any.
    1. Change to the ansible directory: run `cd ~/ansible/` .
    1. Edit list_buckets.yml
        1. Set namespace_name to the value you copied from the result of `oci os ns get` (in "Try the OCI CLI", above)
        1. Set compartment_id to the compartment OCID from Menu > Identity > Compartments of the OCI web console 
    1. Run `ansible-playbook list_buckets.yml` . Expect the result to include "ok=3", indicating that all three tasks returned "ok".
    1. Learn more about Ansible for OCI on the [Cloud Modules page of the Oracle Cloud Infrastructure Ansible Modules site](https://oracle-cloud-infrastructure-ansible-modules.readthedocs.io/en/latest/modules/list_of_cloud_modules.html).

## Run a Vagrant machine that runs MySQL Server 5.7 for access by MySQL Workbench

Run a Vagrant machine that runs Oracle Linux, MySQL Server 5.7, Java 8 SDK, and gdb; and access it with MySQL Workbench, or the command line, from the Vagrant host (your computer).

1. If you haven't yet installed Vagrant and cloned this repository, then:
    1. Download and install [Vagrant](http://vagrantup.com).
    1. At the command line, using a Bash shell, clone this repo: run `git clone https://github.com/gordonIanJ/vagrant-oracle-cloud-infrastructure.git`.
1.Change to the resultant directory: run `cd vagrant-oracle-cloud-infrastructure`.
1. Run the Vagrant machine named “mysql”: run `vagrant up mysql`.
1. SSH to the newly-created Vagrant machine: run `vagrant ssh mysql`.
1. Start mysql server: run `sudo systemctl start mysqld`.
1. Get the temporary password for mysql server: run `sudo grep 'temporary password' /var/log/mysqld.log`. Note/copy the password.
1. Run the interactive hardener to secure mysql server: run `sudo mysql_secure_installation`. **Note the new root password when you set it**.
1. On the Vagrant host (your computer), download and install [MySQL Workbench](TODO).
1. Ensure there is no entry (line) for localhost port 2222 or 127.0.0.1 port 2222 in the known_hosts file in the .ssh/ directory in your home directory. Delete the line if it exists.
1. Open MySQL Workbench, and set up a new connection as per [Vagrant and MySQL Workbench](https://richjenks.com/vagrant-and-mysql-workbench/) (**with a single exception:** set the password for the root user of MySQL to the one you created when you ran the interactive hardener earlier). 