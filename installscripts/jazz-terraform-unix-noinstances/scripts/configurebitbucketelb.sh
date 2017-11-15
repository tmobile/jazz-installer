#!/bin/bash

bitbucketelb_dns_name=$1
chefconfigDir_bitbucketelbconfig_json=$2
jenkinsattribsfile=$3
jenkinspropertiesfile=$4
bitbucketclient=$5
inst_stack_prefix=$6
jazz_admin=$7

echo '{ "bitbucketelb.dns_name": "'$bitbucketelb_dns_name'" }' > $chefconfigDir_bitbucketelbconfig_json
sed -i "s/default\['bitbucketelb'\].*.$/default['bitbucketelb']='$bitbucketelb_dns_name'/g"  $jenkinsattribsfile
sed -i "s/REPO_BASE=.*.$/REPO_BASE=$bitbucketelb_dns_name:7990/g" $jenkinspropertiesfile
sed -i "s/BITBUCKETELB=.*.$/BITBUCKETELB=$bitbucketelb_dns_name/g" $bitbucketclient

# as per somanchi on 07/16/2017 these config.json doesnt need to change for any job
#sed -i 's|"BIT_BUCKET_URL":".*.projects|"BIT_BUCKET_URL":"http://'${bitbucketelb_dns_name}':7990\/projects|' ./jazz-core/create-serverless-service/config/dev-config.json
#sed -i 's|"BIT_BUCKET_URL":".*.projects|"BIT_BUCKET_URL":"http://'${bitbucketelb_dns_name}':7990\/projects|' ./jazz-core/create-serverless-service/config/stg-config.json
#sed -i 's|"BIT_BUCKET_URL":".*.projects|"BIT_BUCKET_URL":"http://'${bitbucketelb_dns_name}':7990\/projects|' ./jazz-core/create-serverless-service/config/prod-config.json

#sed -i 's|"BIT_BUCKET_URL":".*.projects|"BIT_BUCKET_URL":"http://'${bitbucketelb_dns_name}':7990\/projects|' ./jazz-core/delete-serverless-service/config/dev-config.json
#sed -i 's|"BIT_BUCKET_URL":".*.projects|"BIT_BUCKET_URL":"http://'${bitbucketelb_dns_name}':7990\/projects|' ./jazz-core/delete-serverless-service/config/stg-config.json
#sed -i 's|"BIT_BUCKET_URL":".*.projects|"BIT_BUCKET_URL":"http://'${bitbucketelb_dns_name}':7990\/projects|' ./jazz-core/delete-serverless-service/config/prod-config.json

#Modify platform_services config files
sed -i 's/"services_table": ".*.$/"services_table": "'$inst_stack_prefix'_services_dev",/g' ./jazz-core/platform_services/config/dev-config.json
sed -i 's/"services_table": ".*.$/"services_table": "'$inst_stack_prefix'_services_stg",/g' ./jazz-core/platform_services/config/stg-config.json
sed -i 's/"services_table": ".*.$/"services_table": "'$inst_stack_prefix'_services_prod",/g' ./jazz-core/platform_services/config/prod-config.json

sed -i 's/"admin_users": ".*.$/"admin_users": "'$jazz_admin'"/g' ./jazz-core/platform_services/config/dev-config.json
