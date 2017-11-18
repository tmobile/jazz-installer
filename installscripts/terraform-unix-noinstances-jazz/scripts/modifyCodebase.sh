#!/bin/bash

securityGroupIds=$1
subnetIds=$2
iamRoleARN=$3
region=$4
stackprefix=$5

sed -i "s/securityGroupIds.*.$/securityGroupIds: $securityGroupIds/g" ./jazz-core/api-template-java/deployment-env.yml
sed -i "s/subnetIds.*.$/subnetIds: $subnetIds/g" ./jazz-core/api-template-java/deployment-env.yml
sed -i "s=iamRoleARN.*.$=iamRoleARN: $iamRoleARN=g" ./jazz-core/api-template-java/deployment-env.yml
sed -i "s/region.*.$/region: $region/g" ./jazz-core/api-template-java/deployment-env.yml

sed -i "s/securityGroupIds.*.$/securityGroupIds: $securityGroupIds/g" ./jazz-core/api-template-nodejs/deployment-env.yml
sed -i "s/subnetIds.*.$/subnetIds: $subnetIds/g" ./jazz-core/api-template-nodejs/deployment-env.yml
sed -i "s=iamRoleARN.*.$=iamRoleARN: $iamRoleARN=g" ./jazz-core/api-template-nodejs/deployment-env.yml
sed -i "s/region.*.$/region: $region/g" ./jazz-core/api-template-nodejs/deployment-env.yml



sed -i "s/securityGroupIds.*.$/securityGroupIds: $securityGroupIds/g" ./jazz-core/create-serverless-service/deployment-env.yml
sed -i "s/subnetIds.*.$/subnetIds: $subnetIds/g" ./jazz-core/create-serverless-service/deployment-env.yml
sed -i "s=iamRoleARN.*.$=iamRoleARN: $iamRoleARN=g" ./jazz-core/create-serverless-service/deployment-env.yml
sed -i "s/region.*.$/region: $region/g" ./jazz-core/create-serverless-service/deployment-env.yml


sed -i "s/securityGroupIds.*.$/securityGroupIds: $securityGroupIds/g" ./jazz-core/delete-serverless-service/deployment-env.yml
sed -i "s/subnetIds.*.$/subnetIds: $subnetIds/g" ./jazz-core/delete-serverless-service/deployment-env.yml
sed -i "s=iamRoleARN.*.$=iamRoleARN: $iamRoleARN=g" ./jazz-core/delete-serverless-service/deployment-env.yml
sed -i "s/region.*.$/region: $region/g" ./jazz-core/delete-serverless-service/deployment-env.yml

sed -i "s/securityGroupIds.*.$/securityGroupIds: $securityGroupIds/g" ./jazz-core/cloud-logs-streamer/deployment-env.yml
sed -i "s/subnetIds.*.$/subnetIds: $subnetIds/g" ./jazz-core/cloud-logs-streamer/deployment-env.yml
sed -i "s=iamRoleARN.*.$=iamRoleARN: $iamRoleARN=g" ./jazz-core/cloud-logs-streamer/deployment-env.yml
sed -i "s/region.*.$/region: $region/g" ./jazz-core/cloud-logs-streamer/deployment-env.yml

# Modify platform_services deployment-env.yml file
sed -i "s/securityGroupIds.*.$/securityGroupIds: $securityGroupIds/g" ./jazz-core/platform_services/deployment-env.yml
sed -i "s/subnetIds.*.$/subnetIds: $subnetIds/g" ./jazz-core/platform_services/deployment-env.yml
sed -i "s=iamRoleARN.*.$=iamRoleARN: $iamRoleARN=g" ./jazz-core/platform_services/deployment-env.yml
sed -i "s/region.*.$/region: $region/g" ./jazz-core/platform_services/deployment-env.yml

# Modify is-service-available deployment-env.yml file
sed -i "s/securityGroupIds.*.$/securityGroupIds: $securityGroupIds/g" ./jazz-core/is-service-available/deployment-env.yml
sed -i "s/subnetIds.*.$/subnetIds: $subnetIds/g" ./jazz-core/is-service-available/deployment-env.yml
sed -i "s=iamRoleARN.*.$=iamRoleARN: $iamRoleARN=g" ./jazz-core/is-service-available/deployment-env.yml
sed -i "s/region.*.$/region: $region/g" ./jazz-core/is-service-available/deployment-env.yml

# Modify platform_login deployment-env.yml file
sed -i "s/securityGroupIds.*.$/securityGroupIds: $securityGroupIds/g" ./jazz-core/platform_login/deployment-env.yml
sed -i "s/subnetIds.*.$/subnetIds: $subnetIds/g" ./jazz-core/platform_login/deployment-env.yml
sed -i "s=iamRoleARN.*.$=iamRoleARN: $iamRoleARN=g" ./jazz-core/platform_login/deployment-env.yml
sed -i "s/region.*.$/region: $region/g" ./jazz-core/platform_login/deployment-env.yml

# Modify platform_logout deployment-env.yml file
sed -i "s/securityGroupIds.*.$/securityGroupIds: $securityGroupIds/g" ./jazz-core/platform_logout/deployment-env.yml
sed -i "s/subnetIds.*.$/subnetIds: $subnetIds/g" ./jazz-core/platform_logout/deployment-env.yml
sed -i "s=iamRoleARN.*.$=iamRoleARN: $iamRoleARN=g" ./jazz-core/platform_logout/deployment-env.yml
sed -i "s/region.*.$/region: $region/g" ./jazz-core/platform_logout/deployment-env.yml

# Modify cognito-authorizer deployment-env.yml file
sed -i "s/securityGroupIds.*.$/securityGroupIds: $securityGroupIds/g" ./jazz-core/cognito-authorizer/deployment-env.yml
sed -i "s/subnetIds.*.$/subnetIds: $subnetIds/g" ./jazz-core/cognito-authorizer/deployment-env.yml
sed -i "s=iamRoleARN.*.$=iamRoleARN: $iamRoleARN=g" ./jazz-core/cognito-authorizer/deployment-env.yml
sed -i "s/region.*.$/region: $region/g" ./jazz-core/cognito-authorizer/deployment-env.yml

sed -i "s/securityGroupIds.*.$/securityGroupIds: $securityGroupIds/g" ./jazz-core/api-template-python/deployment-env.yml
sed -i "s/subnetIds.*.$/subnetIds: $subnetIds/g" ./jazz-core/api-template-python/deployment-env.yml
sed -i "s=iamRoleARN.*.$=iamRoleARN: $iamRoleARN=g" ./jazz-core/api-template-python/deployment-env.yml
sed -i "s/region.*.$/region: $region/g" ./jazz-core/api-template-python/deployment-env.yml

sed -i "s/securityGroupIds.*.$/securityGroupIds: $securityGroupIds/g" ./jazz-core/platform-services-handler/deployment-env.yml
sed -i "s/subnetIds.*.$/subnetIds: $subnetIds/g" ./jazz-core/platform-services-handler/deployment-env.yml
sed -i "s=iamRoleARN.*.$=iamRoleARN: $iamRoleARN=g" ./jazz-core/platform-services-handler/deployment-env.yml
sed -i "s/region.*.$/region: $region/g" ./jazz-core/platform-services-handler/deployment-env.yml

sed -i "s/securityGroupIds.*.$/securityGroupIds: $securityGroupIds/g" ./jazz-core/platform_events/deployment-env.yml
sed -i "s/subnetIds.*.$/subnetIds: $subnetIds/g" ./jazz-core/platform_events/deployment-env.yml
sed -i "s=iamRoleARN.*.$=iamRoleARN: $iamRoleARN=g" ./jazz-core/platform_events/deployment-env.yml
sed -i "s/region.*.$/region: $region/g" ./jazz-core/platform_events/deployment-env.yml

sed -i "s/securityGroupIds.*.$/securityGroupIds: $securityGroupIds/g" ./jazz-core/lambda-template-java/deployment-env.yml
sed -i "s/subnetIds.*.$/subnetIds: $subnetIds/g" ./jazz-core/lambda-template-java/deployment-env.yml
sed -i "s=iamRoleARN.*.$=iamRoleARN: $iamRoleARN=g" ./jazz-core/lambda-template-java/deployment-env.yml
sed -i "s/region.*.$/region: $region/g" ./jazz-core/lambda-template-java/deployment-env.yml

sed -i "s/securityGroupIds.*.$/securityGroupIds: $securityGroupIds/g" ./jazz-core/lambda-template-nodejs/deployment-env.yml
sed -i "s/subnetIds.*.$/subnetIds: $subnetIds/g" ./jazz-core/lambda-template-nodejs/deployment-env.yml
sed -i "s=iamRoleARN.*.$=iamRoleARN: $iamRoleARN=g" ./jazz-core/lambda-template-nodejs/deployment-env.yml
sed -i "s/region.*.$/region: $region/g" ./jazz-core/lambda-template-nodejs/deployment-env.yml

sed -i "s/securityGroupIds.*.$/securityGroupIds: $securityGroupIds/g" ./jazz-core/lambda-template-python/deployment-env.yml
sed -i "s/subnetIds.*.$/subnetIds: $subnetIds/g" ./jazz-core/lambda-template-python/deployment-env.yml
sed -i "s=iamRoleARN.*.$=iamRoleARN: $iamRoleARN=g" ./jazz-core/lambda-template-python/deployment-env.yml
sed -i "s/region.*.$/region: $region/g" ./jazz-core/lambda-template-python/deployment-env.yml

# Add the stackname to int serverless-config-packs
sed -i "s/{inst_stack_prefix}/$stackprefix/g" ./jazz-core/serverless-config-pack/serverless-java.yml
sed -i "s/{inst_stack_prefix}/$stackprefix/g" ./jazz-core/serverless-config-pack/serverless-nodejs.yml
sed -i "s/{inst_stack_prefix}/$stackprefix/g" ./jazz-core/serverless-config-pack/serverless-python.yml
