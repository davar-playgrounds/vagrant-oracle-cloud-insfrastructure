
VAGRANT_HOME=$1

# Make an SSH keypair unless it exists
if [ ! -e $VAGRANT_HOME/.ssh/id_rsa ]
  then
    # Answer "y" to interactive prompt(s)...
    # ...while generating an SSH key:
    yes "y" | ssh-keygen -N "" -f $VAGRANT_HOME/.ssh/id_rsa
fi
