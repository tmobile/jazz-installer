#!/bin/bash

JENKINSELB=demo1jenkinselb-1502617005.us-east-1.elb.amazonaws.com
BITBUCKETELB=demo1bitbucketelb-1245462871.us-east-1.elb.amazonaws.com
BASEURL=http://$BITBUCKETELB:7990
USER=jenkins1
PASS=jenkinsadmin
CLIENTJAR=~/atlassian-cli-6.7.1/lib/bitbucket-cli-6.7.0.jar


#create PROJECTS in BITBUCKET
ACTION=createProject --project "SLF"  --name "SLF" --description " created from cli" --public
java -jar $CLIENTJAR -s $BASEURL -u $USER -p $PASS --action $ACTION 
ACTION=createProject --project "CAS"  --name "CAS" --description " created from cli" --public
java -jar $CLIENTJAR -s $BASEURL -u $USER -p $PASS --action $ACTION 



# UPLOADS THE REPOSITORIES INTO BITBUCKET
./bitbucketpush.sh $BITBUCKETELB
#CALLS JENKINS JOB TO INSTALL Serverless application on AWS
curl  http://$JENKINSELB:8080/job/inst_deploy_createservice/build?token=triggerCreateService --user jenkinsadmin:jenkinsadmin
