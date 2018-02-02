#!/bin/bash

securityGroupIds=$1
subnetIds=$2
stackprefix=$3
jenkinsjsonpropsfile=$4
role="_lambda2_basic_execution_1"
iam=$stackprefix$role

secGpIds="\""
sbIds="\""
quote="\",\""

for element in "${securityGroupIds[@]}"
do
 secGpIds=$secGpIds$element$quote
done

for element in "${subnetIds[@]}"
do
  sbIds=$sbIds$element$quote
done

sbIds=${sbIds::-2}
secGpIds=${secGpIds::-2}


sed -i "s/SECURITY_GROUP_IDS\".*.$/SECURITY_GROUP_IDS\": \[$secGpIds\],/g" $jenkinsjsonpropsfile
sed -i "s/SUBNET_IDS\".*.$/SUBNET_IDS\": \[$sbIds\],/g" $jenkinsjsonpropsfile
sed -i "s/LAMBDA_EXECUTION_ROLE\".*.$/LAMBDA_EXECUTION_ROLE\": \"$iam\"/g" $jenkinsjsonpropsfile
