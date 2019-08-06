#!/bin/bash

#yum -y makecache
#yum -y upgrade
#yum -y update

# Enable the ol7_developer and ol7_developer_epel areas of the public-yum-ol7 yum repo
yum-config-manager --enable ol7_developer ol7_developer_epel && \

yum -y install ansible terraform python-oci-sdk python-oci-cli \
    bzip2 cpio zip unzip dos2unix dialog curl jq git \
    iputils wget screen tmux byobu elinks
