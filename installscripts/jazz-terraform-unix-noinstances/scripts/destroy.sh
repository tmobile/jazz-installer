#!/bin/bash
date

stack_name=""
currentDir=`pwd`
loopIndx=0

if [ "$1" == "" ]; then
     echo "Please provide Argument [all or frameworkonly]"
     exit 1
fi

echo "parameter::$1"

if [ "$1" != "all" ] && [ "$1" != "frameworkonly" ]; then
     echo "Please provide Argument [all or frameworkonly]"
     exit 1
fi

# Rename any stack_deletion out files if any
for x in ~/jazz-installer/stack_de*.out
do
    if [ -f "$x" ]
    then
        mv $x ${x%.out}-old.out
    fi
done

echo " ======================================================="
echo " The following stack has been marked for deletion in AWS"
echo " ________________________________________________"
cd installscripts/jazz-terraform-unix-noinstances
terraform state list

echo " ======================================================="

echo " Destroying of stack initiated!!! "
echo " Execute  'tail -f stack_deletion_X.out' in below directory to see the stack deletion progress (X=1 or 2 or 3)"
echo $currentDir

echo " ======================================================="

# Calling the Delete platform services py script
if [ "$1" == "all" ]; then
    #Deleting the event source handler mapping
    /usr/bin/python scripts/DeleteEventSourceMapping.py $stack_name

    #Deleting Platform services
    /usr/bin/python scripts/DeleteStackPlatformServices.py $stack_name true

    #Deleting Cloud Front Distributions
    cd ~/jazz-installer/installscripts/jazz-terraform-unix-noinstances
    /usr/bin/python scripts/DeleteStackCloudFrontDists.py $stack_name true

    echo "Destroy cloudfronts"
    cd ~/jazz-installer/installscripts/jazz-terraform-unix-noinstances
    /usr/bin/python scripts/DeleteStackCloudFrontDists.py $stack_name false

    while [ $loopIndx -le 2 ];
    do
        ((loopIndx++))
        nohup terraform destroy --force >> ../../stack_deletion_$loopIndx.out &&

        echo "Waiting for terraform to finish updating the logs for 30 secs"
        sleep 30s
        if (grep -q "Error applying plan" ../../stack_deletion_$loopIndx.out); then
            echo "Found error in terraform destroy. In run=" + $loopIndx + ", starting to destroy again"
            terraform state list
        else
            echo "Terraform destroy success"
            break
        fi
    done

    if [ $loopIndx -ge 3 ]; then
        exit 1
    fi

fi

if [ "$1" == "frameworkonly" ]; then
    #Deleting the event source handler mapping
    /usr/bin/python scripts/DeleteEventSourceMapping.py $stack_name

    #Deleting Platform services
    /usr/bin/python scripts/DeleteStackPlatformServices.py $stack_name false

    #Calling the terraform destroy
    # TODO This is a code smell, if we have correctly declared resource dependencies in our terraform scripts, terraform should destroy everything we created without us having to maintan a list of every resource and pass it to `terraform destroy` like this.
    terraform destroy -target=aws_kinesis_stream.kinesis_stream_prod -target=aws_iam_role_policy_attachment.kinesisaccess -target=aws_dynamodb_table.dynamodb-Environments_Dev -target=aws_dynamodb_table.dynamodb-Environments_Stg -target=aws_dynamodb_table.dynamodb-Environments_Prod -target=aws_dynamodb_table.dynamodb-table_Event_Handler_Stg -target=null_resource.configureExistingBitbucketServer -target=aws_dynamodb_table.dynamodb-Event_Name_Prod -target=aws_dynamodb_table.dynamodb-Event_Type_Dev -target=aws_s3_bucket.oab-apis-deployment-stg -target=aws_s3_bucket_policy.dev-serverless-static-bucket-contents-policy -target=null_resource.outputVariables -target=aws_cloudfront_distribution.jazz -target=aws_cloudfront_origin_access_identity.origin_access_identity -target=aws_dynamodb_table.dynamodb-Event_Name_Stg -target=aws_iam_role_policy_attachment.cognitopoweruser -target=aws_s3_bucket_policy.stg-serverless-static-bucket-contents-policy -target=aws_s3_bucket_policy.jazz-web-bucket-contents-policy -target=aws_dynamodb_table.dynamodb-table-stg -target=aws_dynamodb_table.dynamodb-table_Event_Handler_Dev -target=aws_s3_bucket.oab-apis-deployment-dev -target=aws_iam_role_policy_attachment.vpccrossaccountaccess -target=aws_s3_bucket_policy.prod-serverless-static-bucket-contents-policy -target=aws_s3_bucket.oab-apis-deployment-prod -target=aws_dynamodb_table.dynamodb-Event_Type_Prod -target=aws_dynamodb_table.dynamodb-table_Event_Handler_Prod -target=data.aws_canonical_user_id.current -target=aws_dynamodb_table.dynamodb-Event_Name_Dev -target=aws_kinesis_stream.kinesis_stream_stg -target=aws_dynamodb_table.dynamodb-Event_Status_Prod -target=aws_dynamodb_table.dynamodb-table-prod -target=aws_dynamodb_table.dynamodb-Event_Status_Dev -target=aws_dynamodb_table.dynamodb-Events_Stg -target=aws_elasticsearch_domain.elasticsearch_domain -target=aws_dynamodb_table.dynamodb-Event_Type_Stg -target=aws_dynamodb_table.dynamodb-Events_Prod -target=aws_kinesis_stream.kinesis_stream_dev -target=null_resource.configureExistingJenkinsServer -target=aws_s3_bucket.jazz-web -target=aws_dynamodb_table.dynamodb-table-dev -target=aws_dynamodb_table.dynamodb-Event_Status_Stg -target=aws_dynamodb_table.dynamodb-Events_Dev -target=aws_cognito_user_pool.pool -target=aws_s3_bucket.jazz_s3_api_doc

    date
    exit 0
fi


cd ~/jazz-installer

if (grep -q "Error applying plan" ./stack_deletion_$loopIndx.out) then
    echo "Error occured in destroy, please refer stack_deletion.out and re-run destroy after resolving the issues."
    exit 1
fi

echo "Proceeding to delete Jazz instance."
shopt -s extglob
sudo rm -rf !(*.out)
sudo rm -rf ../Installer.sh ../atlassian-cli*

date
