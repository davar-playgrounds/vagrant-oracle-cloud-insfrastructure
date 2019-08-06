
VAGRANT_HOME=$1

echo "Please enter the OCI Region:"
read OCI_REGION 

echo "Please enter the Tenancy OCID:"
read TENANCY_OCID

echo "Please enter the User OCID:"
read USER_OCID

FINGERPRINT=$(sudo cat $VAGRANT_HOME/.oci/oci_api_key_fingerprint)
PRIVATE_KEY_PATH=$VAGRANT_HOME/.oci/oci_api_key.pem
SSH_PUBLIC_KEY=$(sudo cat $VAGRANT_HOME/.ssh/id_rsa.pub)
SSH_PRIVATE_KEY=$(sudo cat $VAGRANT_HOME/.ssh/id_rsa)

# Write the terraform.tfvars i.e. config file
cat<< EOF > $VAGRANT_HOME/terraform/terraform.tfvars
fingerprint         = "$FINGERPRINT"
private_key_path    = "$PRIVATE_KEY_PATH"
ssh_public_key      = "$SSH_PUBLIC_KEY"
region              = "$OCI_REGION"
tenancy_ocid        = "$TENANCY_OCID"
user_ocid           = "$USER_OCID"
EOF

# Write the Oracle Cloud Infrastructure SDK and CLI config file
cat<< EOF > $VAGRANT_HOME/.oci/config
[DEFAULT] 
user        = $USER_OCID
fingerprint = $FINGERPRINT 
key_file    = $PRIVATE_KEY_PATH 
tenancy     = $TENANCY_OCID 
region      = $OCI_REGION
EOF

oci setup repair-file-permissions --file /home/vagrant/.oci/config