#!/bin/bash

property_key=$1
property_value=$2
property_file=$3


property_value=$(sed 's/[]\/$*.^|[]/\\&/g' <<< $property_value)

if [ '$3' == "../cookbooks/jenkins/files/node/jenkins-conf.properties" ] ; then
    sed -i "s/$property_key.*.$/$property_key=$property_value/g" $property_file
        
else 
	sed -i "s/$property_key\".*.$/$property_key\": \"$property_value\"/g" $property_file
       
fi




