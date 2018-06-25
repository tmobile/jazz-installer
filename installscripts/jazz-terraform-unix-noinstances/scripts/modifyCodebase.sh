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

platform_services=()
cd ./jazz-core
for d in core/* ; do
  reponame="${d##*/}"
  if [[ $reponame != "jazz-ui"  && $reponame != "jazz-web" ]] ; then
		platform_services+=("$reponame")
  fi
  done
cd ..

servicename="_services_prod"
tablename=$stackprefix$servicename
timestamp=`date --utc +%FT%T`

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

  if [ $element == "jazz_email" ] || [ $element == "jazz_usermanagement" ] || [ $element == "jazz_codeq" ] || [ $element == "jazz_metrics" ]; then
	  aws dynamodb put-item --table-name $tablename --item '{
	  "SERVICE_ID":{"S":"'$uuid'"},
	  "SERVICE_CREATED_BY":{"S":"'$jazz_admin'"},
	  "SERVICE_DOMAIN":{"S":"jazz"},
	  "SERVICE_NAME":{"S":"'$service_name'"},
	  "SERVICE_RUNTIME":{"S":"nodejs"},
	  "SERVICE_STATUS":{"S":"active"},
	  "TIMESTAMP":{"S":"'$timestamp'"},
	  "SERVICE_TYPE":{"S":"api"},
	  "SERVICE_METADATA":{"M":{
				  "securityGroupIds":{"S":"'$securityGroupIds'"},
				  "subnetIds":{"S":"'$subnetIds'"},
				  "iamRoleARN":{"S":"'$iamRoleARN'"},
				  "providerMemorySize":{"S":"256"},
				  "providerRuntime":{"S":"nodejs6.10"},
				  "providerTimeout":{"S":"160"}
			    }
			}
	  }'
	elif [ $element == "jazz_cognito-authorizer" ] || [ $element == "jazz_cloud-logs-streamer" ] || [ $element == "jazz_services-handler" ]  || [ $element == "jazz_events-handler" ] || [ $element == "jazz_environment-event-handler" ] || [ $element == "jazz_deployments-event-handler" ] || [ $element == "jazz_asset-event-handler" ] || [ $element == "jazz_slack-event-handler" ]; then
			aws dynamodb put-item --table-name $tablename --item '{
			  "SERVICE_ID":{"S":"'$uuid'"},
			  "SERVICE_CREATED_BY":{"S":"'$jazz_admin'"},
			  "SERVICE_DOMAIN":{"S":"jazz"},
			  "SERVICE_NAME":{"S":"'$service_name'"},
			  "SERVICE_RUNTIME":{"S":"nodejs"},
			  "SERVICE_STATUS":{"S":"active"},
			  "TIMESTAMP":{"S":"'$timestamp'"},
			  "SERVICE_TYPE":{"S":"function"},
			  "SERVICE_METADATA":{"M":{
						  "securityGroupIds":{"S":"'$securityGroupIds'"},
						  "subnetIds":{"S":"'$subnetIds'"},
						  "iamRoleARN":{"S":"'$iamRoleARN'"},
						  "providerMemorySize":{"S":"256"},
						  "providerRuntime":{"S":"nodejs4.3"},
						  "providerTimeout":{"S":"160"}
						}
					}
			  }'
	else
		aws dynamodb put-item --table-name $tablename --item '{
		  "SERVICE_ID":{"S":"'$uuid'"},
		  "SERVICE_CREATED_BY":{"S":"'$jazz_admin'"},
		  "SERVICE_DOMAIN":{"S":"jazz"},
		  "SERVICE_NAME":{"S":"'$service_name'"},
		  "SERVICE_RUNTIME":{"S":"nodejs"},
		  "SERVICE_STATUS":{"S":"active"},
		  "TIMESTAMP":{"S":"'$timestamp'"},
		  "SERVICE_TYPE":{"S":"api"},
		  "SERVICE_METADATA":{"M":{
					  "securityGroupIds":{"S":"'$securityGroupIds'"},
					  "subnetIds":{"S":"'$subnetIds'"},
					  "iamRoleARN":{"S":"'$iamRoleARN'"},
					  "providerMemorySize":{"S":"256"},
					  "providerRuntime":{"S":"nodejs4.3"},
					  "providerTimeout":{"S":"160"}
					}
				}
		  }'

   fi
done
