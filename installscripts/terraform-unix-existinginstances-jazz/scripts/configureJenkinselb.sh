#!/bin/bash

JENKINSELB=$1
jenkinsattribsfile=$2
bitbucketclient=$3
sed -i "s/default\['jenkinselb'\].*.$/default['jenkinselb']='$JENKINSELB'/g"  $jenkinsattribsfile
sed -i "s/JENKINSELB=.*.$/JENKINSELB=$JENKINSELB/g" $3

sed -i 's|"JOB_BUILD_URL.*.job|"JOB_BUILD_URL":"http:\/\/'${JENKINSELB}':8080\/job|g' ./jazz-core/create-serverless-service/config/dev-config.json
sed -i 's|"JOB_BUILD_URL.*.job|"JOB_BUILD_URL":"http:\/\/'${JENKINSELB}':8080\/job|g' ./jazz-core/create-serverless-service/config/prod-config.json
sed -i 's|"JOB_BUILD_URL.*.job|"JOB_BUILD_URL":"http:\/\/'${JENKINSELB}':8080\/job|g' ./jazz-core/create-serverless-service/config/stg-config.json

sed -i 's|"DELETE_SERVICE_JOB_URL.*.job|"DELETE_SERVICE_JOB_URL":"http:\/\/'${JENKINSELB}':8080\/job|g' ./jazz-core/delete-serverless-service/config/dev-config.json
sed -i 's|"DELETE_SERVICE_JOB_URL.*.job|"DELETE_SERVICE_JOB_URL":"http:\/\/'${JENKINSELB}':8080\/job|g' ./jazz-core/delete-serverless-service/config/prod-config.json
sed -i 's|"DELETE_SERVICE_JOB_URL.*.job|"DELETE_SERVICE_JOB_URL":"http:\/\/'${JENKINSELB}':8080\/job|g' ./jazz-core/delete-serverless-service/config/stg-config.json
