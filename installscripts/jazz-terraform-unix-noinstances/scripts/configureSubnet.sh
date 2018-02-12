#!/bin/bash

#Expecting Sg and subnetIds are coming as comma seperated
securityGroupIds=$1
subnetIds=$2
stackprefix=$3
jenkinsjsonpropsfile=$4
role="_lambda2_basic_execution_1"
iam=$stackprefix$role

sed -i "s/\"SECURITY_GROUP_IDS\".*\"\"/\"SECURITY_GROUP_IDS\" : \"$securityGroupIds\"/g" $property_file_json
sed -i "s/\"SUBNET_IDS\".*\"\"/\"SUBNET_IDS\" : \"$subnetIds\"/g" $property_file_json
sed -i "s/\"LAMBDA_EXECUTION_ROLE\".*\"\"/\"LAMBDA_EXECUTION_ROLE\" : \"$iam\"/g" $property_file_json

