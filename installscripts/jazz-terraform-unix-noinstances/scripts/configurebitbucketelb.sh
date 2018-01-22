#!/bin/bash

bitbucketelb_dns_name=$1
jenkinsattribsfile=$2
jenkinspropertiesfile=$3
jenkinsjsonpropertiesfile=$4
bitbucketclient=$5
inst_stack_prefix=$6
jazz_admin=$7

sed -i "s/default\['bitbucketelb'\].*.$/default['bitbucketelb']='$bitbucketelb_dns_name'/g"  $jenkinsattribsfile
sed -i "s/REPO_BASE=.*.$/REPO_BASE=$bitbucketelb_dns_name/g" $jenkinspropertiesfile
sed -i "s/REPO_BASE\".*.$/REPO_BASE\": \"$bitbucketelb_dns_name\",/g" $jenkinsjsonpropertiesfile


sed -i "s/BITBUCKETELB=.*.$/BITBUCKETELB=$bitbucketelb_dns_name/g" $bitbucketclient

#Modify platform_services config files
sed -i 's/"services_table": ".*.$/"services_table": "'$inst_stack_prefix'_services_dev",/g' ./jazz-core/platform_services/config/dev-config.json
sed -i 's/"services_table": ".*.$/"services_table": "'$inst_stack_prefix'_services_stg",/g' ./jazz-core/platform_services/config/stg-config.json
sed -i 's/"services_table": ".*.$/"services_table": "'$inst_stack_prefix'_services_prod",/g' ./jazz-core/platform_services/config/prod-config.json

sed -i 's/"admin_users": ".*.$/"admin_users": "'$jazz_admin'"/g' ./jazz-core/platform_services/config/dev-config.json
sed -i 's/"admin_users": ".*.$/"admin_users": "'$jazz_admin'"/g' ./jazz-core/platform_services/config/stg-config.json
sed -i 's/"admin_users": ".*.$/"admin_users": "'$jazz_admin'"/g' ./jazz-core/platform_services/config/prod-config.json
