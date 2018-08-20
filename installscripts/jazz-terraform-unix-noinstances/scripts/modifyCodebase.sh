#!/bin/bash

securityGroupIds=$1
subnetIds=$2
iamRoleARN=$3
region=$4
stackprefix=$5
jazz_admin=$6

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

lambda_services=("jazz_cognito-authorizer" "jazz_cloud-logs-streamer" "jazz_services-handler" "jazz_events-handler" "jazz_environment-event-handler" "jazz_deployments-event-handler" "jazz_asset-event-handler" "jazz_slack-event-handler")
nodejs61_service=("jazz_email" "jazz_usermanagement" "jazz_codeq" "jazz_metrics" "jazz_slack-event-handler" "jazz_is-slack-channel-available" "jazz_admin" "jazz_slack-channel" "jazz_deployments-event-handler" "jazz_assets")

platform_services=()
cd ./jazz-core
for d in core/* ; do
  reponame="${d##*/}"
  if [[ $reponame != "jazz_ui"  && $reponame != "jazz-web" ]] ; then
		platform_services+=("$reponame")
  fi
  done
cd ..

servicename="_services_prod"
tablename=$stackprefix$servicename
timestamp=`date --utc +%FT%T`
service_type="
provider_runtime="

for element in "${platform_services[@]}"
do
  uuid=`uuidgen -t`
  echo -n > ./jazz-core/core/$element/deployment-env.yml
  echo "service_id: "$uuid >> ./jazz-core/core/$element/deployment-env.yml

  if [[ $element =~ ^jazz ]] ; then
    service_name="${element:5}"
  else
    service_name=$element
  fi

  if [[ $(inArray "${lambda_services[@]}" "$element") ]]; then
			service_type="function"
			if [[ $(inArray "${nodejs61_service[@]}" "$element") ]]; then
				provider_runtime="nodejs6.10"
			else
				provider_runtime="nodejs4.3"
			fi
 else
			service_type="api"
			if [[ $(inArray "${nodejs61_service[@]}" "$element") ]]; then
				provider_runtime="nodejs6.10"
			else
				provider_runtime="nodejs4.3"
			fi
 fi

#Updating to service catalog
	aws dynamodb put-item --table-name $tablename --item '{
	  "SERVICE_ID":{"S":"'$uuid'"},
	  "SERVICE_CREATED_BY":{"S":"'$jazz_admin'"},
	  "SERVICE_DOMAIN":{"S":"jazz"},
	  "SERVICE_NAME":{"S":"'$service_name'"},
	  "SERVICE_RUNTIME":{"S":"nodejs"},
	  "SERVICE_STATUS":{"S":"active"},
	  "TIMESTAMP":{"S":"'$timestamp'"},
	  "SERVICE_TYPE":{"S":"'$service_type'"},
	  "SERVICE_METADATA":{"M":{
				  "securityGroupIds":{"S":"'$securityGroupIds'"},
				  "subnetIds":{"S":"'$subnetIds'"},
				  "iamRoleARN":{"S":"'$iamRoleARN'"},
				  "providerMemorySize":{"S":"256"},
				  "providerRuntime":{"S":"'$provider_runtime'"},
				  "providerTimeout":{"S":"160"}
			    }
			}
	  }'

done
