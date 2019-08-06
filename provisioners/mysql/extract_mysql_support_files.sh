#!/bin/bash

for file in $(ls |egrep ".*\.tgz$")
do
    tar xvfz $file
done

for file in $(ls |egrep ".*\.bz2$")
do
    tar xvfj $file
done
