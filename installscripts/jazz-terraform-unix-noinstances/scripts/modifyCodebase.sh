#!/bin/bash

securityGroupIds=$1
subnetIds=$2
iamRoleARN=$3
region=$4
stackprefix=$5
jazz_admin=$6

# Add the stackname to int serverless-config-packs
sed -i "s/{inst_stack_prefix}/$stackprefix/g" ./jazz-core/serverless-config-pack/serverless-java.yml
sed -i "s/{inst_stack_prefix}/$stackprefix/g" ./jazz-core/serverless-config-pack/serverless-nodejs.yml
sed -i "s/{inst_stack_prefix}/$stackprefix/g" ./jazz-core/serverless-config-pack/serverless-python.yml

#-------------------------------------------

platform_services=("cognito-authorizer" "platform_logs" "platform_usermanagement" "platform-services-handler" "platform_events" "platform_services" "platform_logout" "platform_login" "cloud-logs-streamer" "is-service-available" "delete-serverless-service" "create-serverless-service" "platform_email" )
servicename="_services_prod"
tablename=$stackprefix$servicename
timestamp=`date --utc +%FT%T`

for element in "${platform_services[@]}"
do
  uuid=`uuidgen -t`
  echo -n > ./jazz-core/$element/deployment-env.yml
  echo "service_id: "$uuid >> ./jazz-core/$element/deployment-env.yml
 
  if [[ $element =~ ^platform ]] ; then
    service_name="${element:9}"
  else
    service_name=$element
  fi
  
  if [ $element == "platform_email" ] ; then		  
	  aws dynamodb put-item --table-name $tablename --item '{
	  "SERVICE_ID":{"S":"'$uuid'"},
	  "SERVICE_CREATED_BY":{"S":"'$jazz_admin'"},
	  "SERVICE_DOMAIN":{"S":"platform"},
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
				  "providerTimeout":{"S":"160"},
				  "runtime":{"S":"nodejs"}
			    }
			}
	  }'
	elif [ $element == "cloud-logs-streamer" ] || [ $element == "platform-services-handler" ] ; then
			aws dynamodb put-item --table-name $tablename --item '{
			  "SERVICE_ID":{"S":"'$uuid'"},
			  "SERVICE_CREATED_BY":{"S":"'$jazz_admin'"},
			  "SERVICE_DOMAIN":{"S":"platform"},
			  "SERVICE_NAME":{"S":"'$service_name'"},
			  "SERVICE_RUNTIME":{"S":"nodejs"},
			  "SERVICE_STATUS":{"S":"active"},
			  "TIMESTAMP":{"S":"'$timestamp'"},
			  "SERVICE_TYPE":{"S":"lambda"},
			  "SERVICE_METADATA":{"M":{
						  "securityGroupIds":{"S":"'$securityGroupIds'"},
						  "subnetIds":{"S":"'$subnetIds'"},
						  "iamRoleARN":{"S":"'$iamRoleARN'"},
						  "providerMemorySize":{"S":"256"},
						  "providerRuntime":{"S":"nodejs4.3"},
						  "providerTimeout":{"S":"160"},
						  "runtime":{"S":"nodejs"}
						}
					}
			  }'
	else
		aws dynamodb put-item --table-name $tablename --item '{
		  "SERVICE_ID":{"S":"'$uuid'"},
		  "SERVICE_CREATED_BY":{"S":"'$jazz_admin'"},
		  "SERVICE_DOMAIN":{"S":"platform"},
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
					  "providerTimeout":{"S":"160"},
					  "runtime":{"S":"nodejs"}
					}
				}
		  }' 

   fi
done
