#!/bin/bash

packer_version=1.4.2
if [ ! -f /usr/local/bin/packer ]
then
    yum install -q unzip wget && \

    #echo "About to fetch a zip of Packer from Hashicorp..." && \
    wget https://releases.hashicorp.com/packer/$packer_version/packer_${packer_version}_linux_amd64.zip && \

    #echo "About to unzip Packer..." && \
    unzip packer_${packer_version}_linux_amd64.zip && \

    #echo "About to move packer to /usr/local/bin..." && \ 
    mv ./packer /usr/local/bin/ && \

    #echo "About to remove packer_${packer_version}_linux_amd64.zip..." && \
    rm packer_${packer_version}_linux_amd64.zip
else
    echo "Packer is already installed."
fi
