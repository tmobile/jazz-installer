#!/bin/bash
#TODO this should be ported to python

securityGroupIds=$1
subnetIds=$2
iamRoleARN=$3
stackprefix=$4
jazz_admin=$5
jazz_accountid=$6
region=$7

# Add the stackname to int serverless-config-packs
sed -i "s/{inst_stack_prefix}/$stackprefix/g" ./jazz-core/builds/serverless-config-pack/serverless-java.yml
sed -i "s/{inst_stack_prefix}/$stackprefix/g" ./jazz-core/builds/serverless-config-pack/serverless-nodejs.yml
sed -i "s/{inst_stack_prefix}/$stackprefix/g" ./jazz-core/builds/serverless-config-pack/serverless-python.yml

#-------------------------------------------

function inArray() {
   local n=$#
   local value=${!n}
   for ((i=1;i < $#;i++)) {
       if [ "${!i}" == "${value}" ]; then
       echo "found" #Need one line after then and before return
       return 1
       fi
   }
   return 0
}

function pushToCatalog {
  tablename=$1
  element=$2
  service_type=$3
  deployment_targets=$4
  provider_runtime=$5

  timestamp=$(date --utc +%FT%T)
  uuid=$(uuidgen -t)

  echo -n > "./jazz-core/core/$element/deployment-env.yml"
  echo "service_id: $uuid" >> "./jazz-core/core/$element/deployment-env.yml"

  if [[ $element =~ ^jazz ]] ; then
    service_name="${element:5}"
  else
    service_name=$element
  fi

  aws dynamodb put-item --table-name "$tablename" --item "{
      \"SERVICE_ID\":{\"S\":\"$uuid\"},
      \"SERVICE_CREATED_BY\":{\"S\":\"$jazz_admin\"},
      \"SERVICE_DOMAIN\":{\"S\":\"jazz\"},
      \"SERVICE_NAME\":{\"S\":\"$service_name\"},
      \"SERVICE_RUNTIME\":{\"S\":\"$provider_runtime\"},
      \"SERVICE_STATUS\":{\"S\":\"active\"},
      \"TIMESTAMP\":{\"S\":\"$timestamp\"},
      \"SERVICE_TYPE\":{\"S\":\"$service_type\"},
      \"SERVICE_DEPLOYMENT_TARGETS\": {\"M\": $deployment_targets},
      \"SERVICE_DEPLOYMENT_ACCOUNTS\": {
        \"L\": [{
            \"M\": {
                \"accountId\": {
                    \"S\": \"$jazz_accountid\"
                },
                \"primary\": {
                    \"B\": \"true\"
                },
                \"provider\": {
                    \"S\": \"aws\"
                },
                \"region\": {
                    \"S\": \"$region\"
                }
            }
        }]
      },
      \"SERVICE_METADATA\":{\"M\":{
                  \"securityGroupIds\":{\"S\":\"$securityGroupIds\"},
                  \"subnetIds\":{\"S\":\"$subnetIds\"},
                  \"iamRoleARN\":{\"S\":\"$iamRoleARN\"},
                  \"providerMemorySize\":{\"S\":\"256\"},
                  \"providerRuntime\":{\"S\":\"$provider_runtime\"},
                  \"providerTimeout\":{\"S\":\"160\"}

        }
      }
    }"
}

lambda_services=("jazz_cognito-authorizer" "jazz_cloud-logs-streamer" "jazz_services-handler" "jazz_events-handler" "jazz_environment-event-handler" "jazz_deployments-event-handler" "jazz_asset-event-handler" "jazz_slack-event-handler" "jazz_es-kinesis-log-streamer" "jazz_splunk-kinesis-log-streamer" "jazz_cognito-admin-authorizer" "jazz_token-authorizer" "jazz_apigee-proxy-aws")

platform_services=()
cd ./jazz-core || exit
for d in core/* ; do
  reponame="${d##*/}"
  if [[ $reponame != "jazz_ui"  && $reponame != "jazz-web" ]] ; then
		platform_services+=("$reponame")
  fi
  done
cd ..

servicename="_services_prod"
tablename=$stackprefix$servicename
service_type=""
deployment_targets=""

#Pushing jazz ui to catalog
deployment_targets=('{"website":{"S":"aws_cloudfront"}}')
pushToCatalog "$tablename" "jazz_ui" "ui" "${deployment_targets[@]}" "n/a"

for element in "${platform_services[@]}"
do
  if [[ $(inArray "${lambda_services[@]}" "$element") ]]; then
      service_type="function"
      deployment_targets=('{"function":{"S":"aws_lambda"}}')
  else
      service_type="api"
      deployment_targets=('{"api":{"S":"aws_apigateway"}}')
  fi

# shellcheck disable=SC2086
#Updating to service catalog
provider_runtime="nodejs8.10"
pushToCatalog "$tablename" "$element" "$service_type" "${deployment_targets[@]}" "$provider_runtime"

done
