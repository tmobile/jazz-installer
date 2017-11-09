#!/bin/bash

API_ID_DEV=$1
API_ID_STG=$2
API_ID_PROD=$3
region=$4
jenkinspropsfile=$5
jenkinsattribsfile=$6
env_name_prefix=$7
# as per somanchis request 07/16/2017 both API_KEY and API_ID_DEV are needed and should have the same value
sed -i "s/API_KEY=.*.$/API_KEY=$API_ID_DEV/g" $jenkinspropsfile
sed -i "s/API_ID_DEV=.*.$/API_ID_DEV=$API_ID_DEV/g" $jenkinspropsfile
sed -i "s/API_ID_STG=.*.$/API_ID_STG=$API_ID_STG/g" $jenkinspropsfile
sed -i "s/API_ID_PROD=.*.$/API_ID_PROD=$API_ID_PROD/g" $jenkinspropsfile
sed -i "s/env_name_prefix.*.$/env_name_prefix=$env_name_prefix/g" $jenkinspropsfile
# as per somanchis conversation this will change once he is ready with  conf file. Will also need an npm bulld before pushing it into s3bucket jazz-web
# sed -i "s/{inst_API_KEY\}/$API_ID_DEV/g" ./jazz-core/cloud-api-onboarding-website/app/scripts/script.js
# sed -i "s/{inst_region}/$region/g" ./jazz-core/cloud-api-onboarding-website/app/scripts/script.js
sed -i "s/default\['region'\].*.$/default['region']='$region'/g"  $jenkinsattribsfile

# Changing cloud-api-onboarding-webapp config.json
sed -i "s/{API_GATEWAY_KEY_DEV\}/$API_ID_DEV/g" ./jazz-ui/src/config/config.json
sed -i "s/{inst_region}/$region/g" ./jazz-ui/src/config/config.json

# Changing jazz-web config.json
sed -i "s/{API_GATEWAY_KEY_DEV\}/$API_ID_DEV/g" ./jazz-core/jazz-web/config/config.json
sed -i "s/{inst_region}/$region/g" ./jazz-core/jazz-web/config/config.json
sed -i "s/{API_GATEWAY_KEY_DEV\}/$API_ID_DEV/g" ./jazz-core/jazz-web/config/config.prod.json
sed -i "s/{inst_region}/$region/g" ./jazz-core/jazz-web/config/config.prod.json