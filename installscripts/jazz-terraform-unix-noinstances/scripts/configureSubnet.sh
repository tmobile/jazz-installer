#!/bin/bash

#Expecting Sg and subnetIds are coming as comma seperated
securityGroupIds=$1
subnetIds=$2
stackprefix=$3
jenkinsjsonpropsfile=$4
role="_basic_execution"
iam=$stackprefix$role

sed -i "s/SECURITY_GROUP_IDS\".*.$/SECURITY_GROUP_IDS\": \"$securityGroupIds\",/g" $jenkinsjsonpropsfile
sed -i "s/SUBNET_IDS\".*.$/SUBNET_IDS\": \"$subnetIds\",/g" $jenkinsjsonpropsfile
sed -i "s/LAMBDA_EXECUTION_ROLE\".*.$/LAMBDA_EXECUTION_ROLE\": \"$iam\",/g" $jenkinsjsonpropsfile

