#!/bin/bash

JENKINSELB=$1
jenkinsattribsfile=$2
sed -i 's|"JOB_BUILD_URL.*.job|"JOB_BUILD_URL":"http:\/\/'${JENKINSELB}':8080\/job|g' ./jazz-core/create-serverless-service/config/dev-config.json
sed -i 's|"JOB_BUILD_URL.*.job|"JOB_BUILD_URL":"http:\/\/'${JENKINSELB}':8080\/job|g' ./jazz-core/create-serverless-service/config/prod-config.json
sed -i 's|"JOB_BUILD_URL.*.job|"JOB_BUILD_URL":"http:\/\/'${JENKINSELB}':8080\/job|g' ./jazz-core/create-serverless-service/config/stg-config.json
sed -i "s/default\['jenkinselb'\].*.$/default['jenkinselb']='$JENKINSELB'/g"  $jenkinsattribsfile

