#!/bin/bash

#yum -y makecache
#yum -y upgrade
#yum -y update

# Enable the ol7_developer and ol7_developer_epel areas of the public-yum-ol7 yum repo
yum-config-manager --enable ol7_developer ol7_developer_epel && \

yum -y install bzip2 cpio zip unzip dos2unix dialog curl jq git \
    iputils wget screen tmux byobu elinks augeas gdb \
    java-1.8.0-openjdk-devel mysql mysql-devel mysql-lib mysql-connnector-java \
    glibc.i686 libgcc.x86_64 libgcc_s.so.1 yum-utils

find /etc/yum.repos.d -name oss.oracle.com_ol7_debuginfo.repo >/dev/null 2>&1 || \
yum-config-manager --add-repo http://oss.oracle.com/ol7/debuginfo && \
yum-config-manager enable debuginfo && \
debuginfo-install -y glibc.i686 glibc.x86_64 libgcc.i686
