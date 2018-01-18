#!/bin/bash

API_ID_DEV=$1
API_ID_STG=$2
API_ID_PROD=$3
region=$4
jenkinspropsfile=$5
jenkinsjsonpropsfile=$6
jenkinsattribsfile=$7
env_name_prefix=$8


#Both API_KEY and API_ID_DEV are needed and should have the same value
sed -i "s/API_KEY=.*.$/API_KEY=$API_ID_PROD/g" $jenkinspropsfile
sed -i "s/API_ID_DEV=.*.$/API_ID_DEV=$API_ID_DEV/g" $jenkinspropsfile
sed -i "s/API_ID_STG=.*.$/API_ID_STG=$API_ID_STG/g" $jenkinspropsfile
sed -i "s/API_ID_PROD=.*.$/API_ID_PROD=$API_ID_PROD/g" $jenkinspropsfile
sed -i "s/env_name_prefix.*.$/env_name_prefix=$env_name_prefix/g" $jenkinspropsfile


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
