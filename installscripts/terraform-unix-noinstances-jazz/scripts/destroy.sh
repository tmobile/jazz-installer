#!/bin/bash
date

stack_name=""
currentDir=`pwd`

if [ "$1" == "" ]; then
     echo "Please provide Argument [all or frameworkonly]"
     exit 1
fi

echo "parameter::$1"

if [ "$1" != "all" ] && [ "$1" != "frameworkonly" ]; then
     echo "Please provide Argument [all or frameworkonly]"
     exit 1
fi


echo " ======================================================="
echo " The following Stack has been marked for deletion in AWS"
echo " ________________________________________________"
cd installscripts/terraform-unix-noinstances-jazz
terraform state list

echo " ======================================================="

echo " Destroying of stack Initiated!!! "
echo " Execute  'tail -f stack_deletion.out' in below directory to see the stack deletion progress"
echo $currentDir

echo " ======================================================="

# Calling the Delete platform services py script

if [ "$1" == "all" ]; then
     /usr/bin/python scripts/DeleteStackPlatformServices.py $stack_name true
fi

if [ "$1" == "frameworkonly" ]; then
     /usr/bin/python scripts/DeleteStackPlatformServices.py $stack_name false
fi

if [ "$1" == "all" ]; then
    nohup terraform destroy --force >>../../stack_deletion.out &

fi

if [ "$1" == "frameworkonly" ]; then
    terraform destroy -target=aws_kinesis_stream.kinesis_stream_prod -target=aws_iam_role_policy_attachment.kinesisaccess -target=aws_dynamodb_table.dynamodb-table_Event_Handler_Stg -target=null_resource.configureExistingBitbucketServer -target=aws_dynamodb_table.dynamodb-Event_Name_Prod -target=aws_dynamodb_table.dynamodb-Event_Type_Dev -target=aws_s3_bucket.oab-apis-deployment-stg -target=aws_s3_bucket_policy.dev-serverless-static-bucket-contents-policy -target=null_resource.outputVariables -target=aws_cloudfront_distribution.jazz -target=aws_cloudfront_origin_access_identity.origin_access_identity -target=aws_dynamodb_table.dynamodb-Event_Name_Stg -target=aws_iam_role_policy_attachment.cognitopoweruser -target=aws_s3_bucket_policy.stg-serverless-static-bucket-contents-policy -target=aws_s3_bucket_policy.jazz-web-bucket-contents-policy -target=aws_dynamodb_table.dynamodb-table-stg -target=aws_dynamodb_table.dynamodb-table_Event_Handler_Dev -target=aws_s3_bucket.oab-apis-deployment-dev -target=aws_iam_role_policy_attachment.vpccrossaccountaccess -target=aws_s3_bucket_policy.prod-serverless-static-bucket-contents-policy -target=aws_s3_bucket.oab-apis-deployment-prod -target=aws_dynamodb_table.dynamodb-Event_Type_Prod -target=aws_dynamodb_table.dynamodb-table_Event_Handler_Prod -target=data.aws_canonical_user_id.current -target=aws_dynamodb_table.dynamodb-Event_Name_Dev -target=aws_kinesis_stream.kinesis_stream_stg -target=aws_dynamodb_table.dynamodb-Event_Status_Prod -target=aws_dynamodb_table.dynamodb-table-prod -target=aws_dynamodb_table.dynamodb-Event_Status_Dev -target=aws_dynamodb_table.dynamodb-Events_Stg -target=aws_s3_bucket.cloudfrontlogs -target=aws_elasticsearch_domain.elasticsearch_domain -target=aws_dynamodb_table.dynamodb-Event_Type_Stg -target=aws_dynamodb_table.dynamodb-Events_Prod -target=aws_kinesis_stream.kinesis_stream_dev -target=null_resource.configureExistingJenkinsServer -target=aws_s3_bucket.jazz-web -target=aws_dynamodb_table.dynamodb-table-dev -target=aws_dynamodb_table.dynamodb-Event_Status_Stg -target=aws_dynamodb_table.dynamodb-Events_Dev -target=null_resource.cognito_user_pool
fi

if [ "$1" != "all" ]; then
    date
	exit 0
fi

cd $currentDir
shopt -s extglob

sudo rm -rf !(*.out)
sudo rm -rf ../rhel7Installer.sh ../atlassian-cli*


date
