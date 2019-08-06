#!/bin/bash

if [[ (! -d $VAGRANT_HOME/ansible/)]]
then 
    mkdir $VAGRANT_HOME/ansible/ && \
    cd $VAGRANT_HOME/ansible && \
    git clone https://github.com/oracle/oci-ansible-modules.git && \
    cd oci-ansible-modules && \
    ./install.py && \
    cd $VAGRANT_HOME && \
    rm -rf ansible 
fi

