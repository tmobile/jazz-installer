#!/bin/bash
aws_secret_access_key=`tr -d '\n' < ~/.aws/credentials | sed -e 's/\[/\n[/g'|grep default|sed -e 's/\[default\]//g' -e 's/aws_secret_access_key/\naws_secret_access_key/g' -e  's/ //g' |grep aws_secret_access_key| cut -d'=' -f2`
aws_access_key=`tr -d '\n' < ~/.aws/credentials | sed -e 's/\[/\n[/g'|grep default|sed -e 's/\[default\]//g' -e 's/aws_secret_access_key/\naws_secret_access_key/g' -e  's/ //g'| grep "aws_access_key" |cut -d'=' -f2`
sed -i "s/AWS_ACCESS_KEY=.*.$/AWS_ACCESS_KEY=$aws_access_key/g" ../cookbooks/jenkins/files/credentials/aws.sh
sed -i "s|AWS_SECRET_KEY=.*.$|AWS_SECRET_KEY=$aws_secret_access_key|g" ../cookbooks/jenkins/files/credentials/aws.sh
date
terraform apply
date
echo " ======================================================="
echo " The following Stack has been created in AWS"
echo " ________________________________________________"
terraform state list
echo " ======================================================="
echo "Please use the following values for checking out JAZZ"
echo " ________________________________________________"
cat ./settings.txt
echo " ======================================================="
echo " Once checkout is done Please execute nohup ./scripts/destroy.sh & in the following directory . This will cleanup the entire Stack"
pwd
echo " ======================================================="

