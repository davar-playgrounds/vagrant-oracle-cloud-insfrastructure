#!/bin/bash
if [ ! -e mysql57-community-release-el7-8.noarch.rpm ]
then
    wget https://repo.mysql.com/mysql57-community-release-el7-8.noarch.rpm && \
    yum localinstall -y mysql57-community-release-el7-8.noarch.rpm && \
    rm mysql57-community-release-el7-8.noarch.rpm
fi
yum list installed -C |grep mysql-community-server || \ 
yum install -y mysql-community-server && \
augtool -s set '/files/etc/my.cnf/target[ . = "mysqld"]/bind-address 0.0.0.0' && \
systemctl enable mysqld
