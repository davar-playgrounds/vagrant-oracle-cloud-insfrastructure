
VAGRANT_HOME=/home/vagrant

oci: ssh_keys oci_keys set_oci_secrets reveal_oci_secrets 

ssh_keys:
	./make/scripts/make_ssh_keys.sh $(VAGRANT_HOME)

oci_keys:
	./make/scripts/make_oci_keys.sh $(VAGRANT_HOME)

reveal_oci_secrets: 
	./make/scripts/reveal_oci_secrets.sh $(VAGRANT_HOME)

set_oci_secrets:
	./make/scripts/write_oci_secrets.sh $(VAGRANT_HOME)