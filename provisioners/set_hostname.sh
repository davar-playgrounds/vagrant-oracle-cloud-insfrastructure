#!/usr/bin/bash

newname = $1 
nmcli general hostname $newname
service systemd-hostnamed restart
hostname 

