
VAGRANT_HOME=$1

echo 
echo Terraform, the OCI SDK, and the OCI CLI have been installed. 
echo The API Keys have been generated, and are saved at $VAGRANT_HOME/.oci/ 
echo
echo Contents of the API Public Key
echo
sudo cat $VAGRANT_HOME/.oci/oci_api_key_public.pem 
echo
echo Please follow the instructions in "How to Upload the Public Key" of
echo https://docs.cloud.oracle.com/Content/API/Concepts/apisigningkey.htm#How2,
echo and note the fingerprint displayed there when the upload is complete.
echo
echo Contents of the API Key Fingerprint. 
echo
sudo cat $VAGRANT_HOME/.oci/oci_api_key_fingerprint
echo
echo The fingerprint should match the one displayed at the OCI console after 
echo upload of the public key.
echo