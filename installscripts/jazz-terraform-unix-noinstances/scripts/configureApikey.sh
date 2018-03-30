#!/bin/bash
DEV_ID=$1
STG_ID=$2
PROD_ID=$3
region=$4
jenkinsjsonpropsfile=$5
jenkinsattribsfile=$6
env_name_prefix=$7

sed -i "s/{AWS_DEV_API_ID_DEFAULT}/$DEV_ID/g" $jenkinsjsonpropsfile
sed -i "s/{AWS_STG_API_ID_DEFAULT}/$STG_ID/g" $jenkinsjsonpropsfile
sed -i "s/{AWS_STG_API_ID_JAZZ}/$STG_ID/g" $jenkinsjsonpropsfile
sed -i "s/{AWS_PROD_API_ID_JAZZ}/$PROD_ID/g" $jenkinsjsonpropsfile
sed -i "s/{AWS_PROD_API_ID_DEFAULT}/$PROD_ID/g" $jenkinsjsonpropsfile
sed -i "s/INSTANCE_PREFIX\".*.$/INSTANCE_PREFIX\": \"$env_name_prefix\",/g" $jenkinsjsonpropsfile

# Changing jazz-web config.json
sed -i "s/{API_GATEWAY_KEY_PROD\}/$PROD_ID/g" ./jazz-core/jazz-web/config/config.json
sed -i "s/{inst_region}/$region/g" ./jazz-core/jazz-web/config/config.json
sed -i "s/{API_GATEWAY_KEY_PROD\}/$PROD_ID/g" ./jazz-core/jazz-web/config/config.prod.json
sed -i "s/{inst_region}/$region/g" ./jazz-core/jazz-web/config/config.prod.json
sed -i "s/default\['region'\].*.$/default['region']='$region'/g"  $jenkinsattribsfile
