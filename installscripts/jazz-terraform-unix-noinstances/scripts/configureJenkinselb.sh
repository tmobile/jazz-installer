#!/bin/bash

JENKINSELB=$1
jenkinsattribsfile=$2

sed -i "s/default\['jenkinselb'\].*.$/default['jenkinselb']='$JENKINSELB'/g"  $jenkinsattribsfile

sed -i 's|"JOB_BUILD_URL.*.job|"JOB_BUILD_URL":"http:\/\/'${JENKINSELB}'\/job|g' ./jazz-core/jazz_create-serverless-service/config/dev-config.json
sed -i 's|"JOB_BUILD_URL.*.job|"JOB_BUILD_URL":"http:\/\/'${JENKINSELB}'\/job|g' ./jazz-core/jazz_create-serverless-service/config/prod-config.json
sed -i 's|"JOB_BUILD_URL.*.job|"JOB_BUILD_URL":"http:\/\/'${JENKINSELB}'\/job|g' ./jazz-core/jazz_create-serverless-service/config/stg-config.json

sed -i 's|"DELETE_SERVICE_JOB_URL.*.job|"DELETE_SERVICE_JOB_URL":"http:\/\/'${JENKINSELB}'\/job|g' ./jazz-core/jazz_delete-serverless-service/config/dev-config.json
sed -i 's|"DELETE_SERVICE_JOB_URL.*.job|"DELETE_SERVICE_JOB_URL":"http:\/\/'${JENKINSELB}'\/job|g' ./jazz-core/jazz_delete-serverless-service/config/prod-config.json
sed -i 's|"DELETE_SERVICE_JOB_URL.*.job|"DELETE_SERVICE_JOB_URL":"http:\/\/'${JENKINSELB}'\/job|g' ./jazz-core/jazz_delete-serverless-service/config/stg-config.json
