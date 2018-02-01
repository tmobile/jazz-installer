#!/bin/bash
API_ID_DEV=$1
API_ID_STG=$2
API_ID_PROD=$3
region=$4
jenkinsjsonpropsfile=$5
jenkinsattribsfile=$6
env_name_prefix=$7


sed -i "s/API_KEY\".*.$/API_KEY\": \"$API_ID_PROD\",/g" $jenkinsjsonpropsfile
sed -i "s/API_ID_DEV\".*.$/API_ID_DEV\": \"$API_ID_DEV\",/g" $jenkinsjsonpropsfile
sed -i "s/API_ID_STG\".*.$/API_ID_STG\": \"$API_ID_STG\",/g" $jenkinsjsonpropsfile
sed -i "s/API_ID_PROD\".*.$/API_ID_PROD\": \"$API_ID_PROD\"/g" $jenkinsjsonpropsfile
sed -i "s/env_name_prefix\".*.$/env_name_prefix\": \"$env_name_prefix\",/g" $jenkinsjsonpropsfile

# Changing jazz-web config.json
sed -i "s/{API_GATEWAY_KEY_PROD\}/$API_ID_PROD/g" ./jazz-core/jazz-web/config/config.json
sed -i "s/{inst_region}/$region/g" ./jazz-core/jazz-web/config/config.json
sed -i "s/{API_GATEWAY_KEY_PROD\}/$API_ID_PROD/g" ./jazz-core/jazz-web/config/config.prod.json
sed -i "s/{inst_region}/$region/g" ./jazz-core/jazz-web/config/config.prod.json
sed -i "s/default\['region'\].*.$/default['region']='$region'/g"  $jenkinsattribsfile
