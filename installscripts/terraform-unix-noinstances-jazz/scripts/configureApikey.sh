#!/bin/bash

API_ID_DEV=$1
API_ID_STG=$2
API_ID_PROD=$3
region=$4
jenkinspropsfile=$5
jenkinsattribsfile=$6
env_name_prefix=$7

#Both API_KEY and API_ID_DEV are needed and should have the same value
sed -i "s/API_KEY=.*.$/API_KEY=$API_ID_DEV/g" $jenkinspropsfile
sed -i "s/API_ID_DEV=.*.$/API_ID_DEV=$API_ID_DEV/g" $jenkinspropsfile
sed -i "s/API_ID_STG=.*.$/API_ID_STG=$API_ID_STG/g" $jenkinspropsfile
sed -i "s/API_ID_PROD=.*.$/API_ID_PROD=$API_ID_PROD/g" $jenkinspropsfile
sed -i "s/env_name_prefix.*.$/env_name_prefix=$env_name_prefix/g" $jenkinspropsfile
sed -i "s/default\['region'\].*.$/default['region']='$region'/g"  $jenkinsattribsfile

# Changing jazz-web config.json
sed -i "s/{API_GATEWAY_KEY_DEV\}/$API_ID_DEV/g" ./jazz-core/jazz-web/config/config.json
sed -i "s/{inst_region}/$region/g" ./jazz-core/jazz-web/config/config.json
sed -i "s/{API_GATEWAY_KEY_DEV\}/$API_ID_DEV/g" ./jazz-core/jazz-web/config/config.prod.json
sed -i "s/{inst_region}/$region/g" ./jazz-core/jazz-web/config/config.prod.json

