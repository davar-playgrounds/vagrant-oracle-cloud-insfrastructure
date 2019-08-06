
VAGRANT_HOME=$1

# Make OCI keys unless they exist
if [ ! -e $VAGRANT_HOME/.oci ]
  then
    echo "About to make OCI keys from SSH kepair"

    # OCI instances use an SSH key pair to authenticate a remote user; so...
    # ...generate keys for OCI:
    mkdir -p $VAGRANT_HOME/.oci 

    # Private Key
    openssl genrsa -out $VAGRANT_HOME/.oci/oci_api_key.pem 2048
    chmod 0700 $VAGRANT_HOME/.oci
    chmod 0600 $VAGRANT_HOME/.oci/oci_api_key.pem

    # Public Key
    openssl rsa -pubout -in $VAGRANT_HOME/.oci/oci_api_key.pem -out $VAGRANT_HOME/.oci/oci_api_key_public.pem

    # Fingerprint
    openssl rsa -in $VAGRANT_HOME/.oci/oci_api_key.pem -pubout -outform DER 2>/dev/null | \
      openssl md5 -c | awk '{print $2}' > $VAGRANT_HOME/.oci/oci_api_key_fingerprint
    chmod 0600 $VAGRANT_HOME/.oci/oci_api_key_public.pem
    chmod 0600 $VAGRANT_HOME/.oci/oci_api_key_fingerprint

    chown -R vagrant $VAGRANT_HOME
fi

