#!/bin/bash

securityGroupIds=$1
subnetIds=$2
iamRoleARN=$3
region=$4
stackprefix=$5
jazz_admin=$6
role=__lambda2_basic_execution_1
iam=$stackprefix$role

JENKINS_JSON_PROPFILE=/home/$SSH_USER/cookbooks/jenkins/files/node/jazz-installer-vars.json

sed -i "s/AWS.SECURITY_GROUP_IDS\".*.$/AWS.SECURITY_GROUP_IDS\": \"$securityGroupIds\",/g" $JENKINS_JSON_PROPFILE
sed -i "s/AWS.SUBNET_IDS\".*.$/AWS.SUBNET_IDS\": \"$subnetIds\",/g" $JENKINS_JSON_PROPFILE
sed -i "s/AWS.LAMBDA_EXECUTION_ROLE\".*.$/AWS.LAMBDA_EXECUTION_ROLE\": \"$iam\"/g" $JENKINS_JSON_PROPFILE

sed -i "s/^securityGroupIds.*.$/securityGroupIds: $securityGroupIds/g" ./jazz-core/api-template-java/deployment-env.yml
sed -i "s/^subnetIds.*.$/subnetIds: $subnetIds/g" ./jazz-core/api-template-java/deployment-env.yml
sed -i "s=^iamRoleARN.*.$=iamRoleARN: $iamRoleARN=g" ./jazz-core/api-template-java/deployment-env.yml
sed -i "s/^region.*.$/region: $region/g" ./jazz-core/api-template-java/deployment-env.yml

sed -i "s/^securityGroupIds.*.$/securityGroupIds: $securityGroupIds/g" ./jazz-core/api-template-nodejs/deployment-env.yml
sed -i "s/^subnetIds.*.$/subnetIds: $subnetIds/g" ./jazz-core/api-template-nodejs/deployment-env.yml
sed -i "s=^iamRoleARN.*.$=iamRoleARN: $iamRoleARN=g" ./jazz-core/api-template-nodejs/deployment-env.yml
sed -i "s/^region.*.$/region: $region/g" ./jazz-core/api-template-nodejs/deployment-env.yml

sed -i "s/^securityGroupIds.*.$/securityGroupIds: $securityGroupIds/g" ./jazz-core/api-template-python/deployment-env.yml
sed -i "s/^subnetIds.*.$/subnetIds: $subnetIds/g" ./jazz-core/api-template-python/deployment-env.yml
sed -i "s=^iamRoleARN.*.$=iamRoleARN: $iamRoleARN=g" ./jazz-core/api-template-python/deployment-env.yml
sed -i "s/^region.*.$/region: $region/g" ./jazz-core/api-template-python/deployment-env.yml

sed -i "s/^securityGroupIds.*.$/securityGroupIds: $securityGroupIds/g" ./jazz-core/lambda-template-java/deployment-env.yml
sed -i "s/^subnetIds.*.$/subnetIds: $subnetIds/g" ./jazz-core/lambda-template-java/deployment-env.yml
sed -i "s=^iamRoleARN.*.$=iamRoleARN: $iamRoleARN=g" ./jazz-core/lambda-template-java/deployment-env.yml
sed -i "s/^region.*.$/region: $region/g" ./jazz-core/lambda-template-java/deployment-env.yml

sed -i "s/^securityGroupIds.*.$/securityGroupIds: $securityGroupIds/g" ./jazz-core/lambda-template-nodejs/deployment-env.yml
sed -i "s/^subnetIds.*.$/subnetIds: $subnetIds/g" ./jazz-core/lambda-template-nodejs/deployment-env.yml
sed -i "s=^iamRoleARN.*.$=iamRoleARN: $iamRoleARN=g" ./jazz-core/lambda-template-nodejs/deployment-env.yml
sed -i "s/^region.*.$/region: $region/g" ./jazz-core/lambda-template-nodejs/deployment-env.yml

sed -i "s/^securityGroupIds.*.$/securityGroupIds: $securityGroupIds/g" ./jazz-core/lambda-template-python/deployment-env.yml
sed -i "s/^subnetIds.*.$/subnetIds: $subnetIds/g" ./jazz-core/lambda-template-python/deployment-env.yml
sed -i "s=^iamRoleARN.*.$=iamRoleARN: $iamRoleARN=g" ./jazz-core/lambda-template-python/deployment-env.yml
sed -i "s/^region.*.$/region: $region/g" ./jazz-core/lambda-template-python/deployment-env.yml

# Add the stackname to int serverless-config-packs
sed -i "s/{inst_stack_prefix}/$stackprefix/g" ./jazz-core/serverless-config-pack/serverless-java.yml
sed -i "s/{inst_stack_prefix}/$stackprefix/g" ./jazz-core/serverless-config-pack/serverless-nodejs.yml
sed -i "s/{inst_stack_prefix}/$stackprefix/g" ./jazz-core/serverless-config-pack/serverless-python.yml

#-------------------------------------------
platform_services=("cognito-authorizer" "logs" "usermanagement" "services-handler" "events" "services" "logout" "login" "cloud-logs-streamer" "is-service-available" "delete-serverless-service" "create-serverless-service" "email" )
servicename="_services_prod"
tablename=$stackprefix$servicename
for element in "${platform_services[@]}"
do
  uuid=`uuidgen -t`
  aws dynamodb put-item --table-name $tablename --item '{
          "SERVICE_ID":{"S":"'$uuid'"},
          "SERVICE_CREATED_BY":{"S":"'$jazz_admin'"},
          "SERVICE_DOMAIN":{"S":"platform"},
          "SERVICE_NAME":{"S":"'$element'"},
          "SERVICE_RUNTIME":{"S":"nodejs"},
          "SERVICE_STATUS":{"S":"active"},
          "SERVICE_METADATA":{"M":{
                          "securityGroupIds":{"S":"'$securityGroupIds'"},
                          "subnetIds":{"S":"'$subnetIds'"},
                          "iamRoleARN":{"S":"'$iamRoleARN'"},
                          "providerMemorySize":{"S":"256"},
                          "providerRuntime":{"S":"nodejs4.3"},
                          "providerTimeout":{"S":"160"},
                          "runtime":{"S":"nodejs"},
                          "service":{"S":"'$element'"},
                          "type":{"S":"api"}
                          }
                  }
          }'
done
