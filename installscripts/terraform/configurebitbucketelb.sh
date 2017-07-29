#!/bin/bash

bitbucketelb_dns_name=$1
chefconfigDir_bitbucketelbconfig_json=$2
jenkinsattribsfile=$3
jenkinspropertiesfile=$4
echo '{ "bitbucketelb.dns_name": "'$bitbucketelb_dns_name'" }' > $chefconfigDir_bitbucketelbconfig_json
sed -i "s/default\['bitbucketelb'\].*.$/default['bitbucketelb']='$bitbucketelb_dns_name'/g"  $jenkinsattribsfile
sed -i "s/REPO_BASE=.*.$/REPO_BASE=$bitbucketelb_dns_name:7990/g" $jenkinspropertiesfile
sed -i 's|"BIT_BUCKET_URL":".*.project|"BIT_BUCKET_URL":"'${bitbucketelb_dns_name}':7990\/projects|g' ./jazz-core/create-serverless-service/config/dev-config.json
sed -i 's|"BIT_BUCKET_URL":".*.project|"BIT_BUCKET_URL":"'${bitbucketelb_dns_name}':7990\/projects|g' ./jazz-core/create-serverless-service/config/prod-config.json
sed -i 's|"BIT_BUCKET_URL":".*.project|"BIT_BUCKET_URL":"'${bitbucketelb_dns_name}':7990\/projects|g' ./jazz-core/create-serverless-service/config/stg-config.json
sed -i "s/BITBUCKETELB.*.$/BITBUCKETELB=$bitbucketelb_dns_name/g" ./bitbucketclient.cmd
