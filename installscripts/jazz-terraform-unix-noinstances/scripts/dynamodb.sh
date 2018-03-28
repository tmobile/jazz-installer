#!/bin/bash

TABLE_FAMILY=$1
TABLE_NAME=$2

case "$TABLE_FAMILY" in
   "EVENT_HANDLER") 
        aws dynamodb put-item --table-name $TABLE_NAME --item "{\"EVENT_HANDLER\":{\"S\":\"CREATE_SERVERLESS_SERVICE\"}}"
        aws dynamodb put-item --table-name $TABLE_NAME --item "{\"EVENT_HANDLER\":{\"S\":\"JENKINS\"}}"
        aws dynamodb put-item --table-name $TABLE_NAME --item "{\"EVENT_HANDLER\":{\"S\":\"ONBOARDING_API\"}}"
        aws dynamodb put-item --table-name $TABLE_NAME --item "{\"EVENT_HANDLER\":{\"S\":\"BITBUCKET\"}}"
        aws dynamodb put-item --table-name $TABLE_NAME --item "{\"EVENT_HANDLER\":{\"S\":\"DELETE_SERVICE_API\"}}"
        aws dynamodb put-item --table-name $TABLE_NAME --item "{\"EVENT_HANDLER\":{\"S\":\"AWS\"}}"
   ;;
   "EVENT_NAME") 
        aws dynamodb put-item --table-name $TABLE_NAME --item "{\"EVENT_NAME\":{\"S\":\"MODIFY_TEMPLATE\"}}"
        aws dynamodb put-item --table-name $TABLE_NAME --item "{\"EVENT_NAME\":{\"S\":\"TRIGGER_FOLDERINDEX\"}}"
        aws dynamodb put-item --table-name $TABLE_NAME --item "{\"EVENT_NAME\":{\"S\":\"CALL_ONBOARDING_WORKFLOW\"}}"
        aws dynamodb put-item --table-name $TABLE_NAME --item "{\"EVENT_NAME\":{\"S\":\"ONBOARDING_COMPLETED\"}}"
        aws dynamodb put-item --table-name $TABLE_NAME --item "{\"EVENT_NAME\":{\"S\":\"RAISE_PR\"}}"
        aws dynamodb put-item --table-name $TABLE_NAME --item "{\"EVENT_NAME\":{\"S\":\"VALIDATE_INPUT\"}}"
        aws dynamodb put-item --table-name $TABLE_NAME --item "{\"EVENT_NAME\":{\"S\":\"CALL_ONBOARDING_SERVICE\"}}"
        aws dynamodb put-item --table-name $TABLE_NAME --item "{\"EVENT_NAME\":{\"S\":\"ADD_WRITE_PERMISSIONS_TO_SERVICE_REPO\"}}"
        aws dynamodb put-item --table-name $TABLE_NAME --item "{\"EVENT_NAME\":{\"S\":\"CREATE_SERVICE\"}}"
        aws dynamodb put-item --table-name $TABLE_NAME --item "{\"EVENT_NAME\":{\"S\":\"UPDATE_ASSET\"}}"
        aws dynamodb put-item --table-name $TABLE_NAME --item "{\"EVENT_NAME\":{\"S\":\"BUILD_MASTER_BRANCH\"}}"
        aws dynamodb put-item --table-name $TABLE_NAME --item "{\"EVENT_NAME\":{\"S\":\"COMMIT_CODE\"}}"
        aws dynamodb put-item --table-name $TABLE_NAME --item "{\"EVENT_NAME\":{\"S\":\"APPROVE_PR\"}}"
        aws dynamodb put-item --table-name $TABLE_NAME --item "{\"EVENT_NAME\":{\"S\":\"CREATE_SERVICE_REPO\"}}"
        aws dynamodb put-item --table-name $TABLE_NAME --item "{\"EVENT_NAME\":{\"S\":\"CALL_DELETE_WORKFLOW\"}}"
        aws dynamodb put-item --table-name $TABLE_NAME --item "{\"EVENT_NAME\":{\"S\":\"LOCK_MASTER_BRANCH\"}}"
        aws dynamodb put-item --table-name $TABLE_NAME --item "{\"EVENT_NAME\":{\"S\":\"DEPLOY_TO_AWS\"}}"
        aws dynamodb put-item --table-name $TABLE_NAME --item "{\"EVENT_NAME\":{\"S\":\"BUILD_CODE_BRANCH\"}}"
        aws dynamodb put-item --table-name $TABLE_NAME --item "{\"EVENT_NAME\":{\"S\":\"ONBOARDING\"}}"
        aws dynamodb put-item --table-name $TABLE_NAME --item "{\"EVENT_NAME\":{\"S\":\"PUSH_TEMPLATE_TO_SERVICE_REPO\"}}"
        aws dynamodb put-item --table-name $TABLE_NAME --item "{\"EVENT_NAME\":{\"S\":\"CREATE_ASSET\"}}"
        aws dynamodb put-item --table-name $TABLE_NAME --item "{\"EVENT_NAME\":{\"S\":\"CLONE_TEMPLATE\"}}"
		aws dynamodb put-item --table-name $TABLE_NAME --item "{\"EVENT_NAME\":{\"S\":\"DELETE_PROJECT\"}}"
		aws dynamodb put-item --table-name $TABLE_NAME --item "{\"EVENT_NAME\":{\"S\":\"BUILD\"}}"
		aws dynamodb put-item --table-name $TABLE_NAME --item "{\"EVENT_NAME\":{\"S\":\"VALIDATE_PRE_BUILD_CONF\"}}"
   ;;
   "EVENT_STATUS") 
        aws dynamodb put-item --table-name $TABLE_NAME --item "{\"EVENT_STATUS\":{\"S\":\"COMPLETED\"}}"
        aws dynamodb put-item --table-name $TABLE_NAME --item "{\"EVENT_STATUS\":{\"S\":\"FAILED\"}}"
        aws dynamodb put-item --table-name $TABLE_NAME --item "{\"EVENT_STATUS\":{\"S\":\"STARTED\"}}"
   ;;
   "EVENT_TYPE") 
        aws dynamodb put-item --table-name $TABLE_NAME --item "{\"EVENT_TYPE\":{\"S\":\"SERVICE_UPDATE\"}}"
        aws dynamodb put-item --table-name $TABLE_NAME --item "{\"EVENT_TYPE\":{\"S\":\"SERVICE_DEPLOYMENT\"}}"
        aws dynamodb put-item --table-name $TABLE_NAME --item "{\"EVENT_TYPE\":{\"S\":\"SERVICE_CREATION\"}}"
        aws dynamodb put-item --table-name $TABLE_NAME --item "{\"EVENT_TYPE\":{\"S\":\"SERVICE_DELETION\"}}"
        aws dynamodb put-item --table-name $TABLE_NAME --item "{\"EVENT_TYPE\":{\"S\":\"SERVICE_ONBOARDING\"}}" 
   ;;
esac


