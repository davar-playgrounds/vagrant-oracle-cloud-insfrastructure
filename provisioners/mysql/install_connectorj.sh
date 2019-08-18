#!/bin/bash

PACKAGE=mysql-connector-java-8.0.17-1.el7.noarch.rpm

if [ ! -e PACKAGE ]
then
	wget https://dev.mysql.com/get/Downloads/Connector-J/${PACKAGE}
	yum localinstall -y $PACKAGE && \
	rm $PACKAGE 
	echo "export CLASSPATH=/usr/share/java/mysql-connector-java.jar:$CLASSPATH" >> /home/vagrant/.bash_profile
fi
