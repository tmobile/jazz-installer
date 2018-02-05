#!/bin/bash

scmbb=$1
bitbucketelbdnsname=$2
jenkinsattribsfile=$3
jenkinsjsonpropertiesfile=$4
bitbucketclient=$5
inst_stack_prefix=$6
jazz_admin=$7

#proceeding
if [ "$scmbb" == 1 ]
then
    sed -i "s/default\['scmelb'\].*.$/default['scmelb']='$bitbucketelbdnsname'/g"  $jenkinsattribsfile
    sed -i "s/REPO_BASE\".*.$/REPO_BASE\": \"$bitbucketelbdnsname\",/g" $jenkinsjsonpropertiesfile
    sed -i "s/BITBUCKETELB=.*.$/BITBUCKETELB=$bitbucketelbdnsname/g" $bitbucketclient
fi

#Modify platform_services config files
sed -i 's/"services_table": ".*.$/"services_table": "'$inst_stack_prefix'_services_dev",/g' ./jazz-core/platform_services/config/dev-config.json
sed -i 's/"services_table": ".*.$/"services_table": "'$inst_stack_prefix'_services_stg",/g' ./jazz-core/platform_services/config/stg-config.json
sed -i 's/"services_table": ".*.$/"services_table": "'$inst_stack_prefix'_services_prod",/g' ./jazz-core/platform_services/config/prod-config.json

sed -i 's/"admin_users": ".*.$/"admin_users": "'$jazz_admin'"/g' ./jazz-core/platform_services/config/dev-config.json
sed -i 's/"admin_users": ".*.$/"admin_users": "'$jazz_admin'"/g' ./jazz-core/platform_services/config/stg-config.json
sed -i 's/"admin_users": ".*.$/"admin_users": "'$jazz_admin'"/g' ./jazz-core/platform_services/config/prod-config.json
