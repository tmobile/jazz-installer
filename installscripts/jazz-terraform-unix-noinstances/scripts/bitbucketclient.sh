#!/bin/bash
sleep 60

#The below two variables are added from  configureJenkinselb.sh and configureBitbucketelb
JENKINSELB=jazz13-jenkinselb-1989578044.us-east-1.elb.amazonaws.com
BITBUCKETELB=jazz13-bitbucketelb-977486464.us-east-1.elb.amazonaws.com
BASEURL=http://$BITBUCKETELB

CLIENTJAR=~/atlassian-cli-6.7.1/lib/bitbucket-cli-6.7.0.jar
region=$1
bitbucketuser=$2
bitbucketpasswd=$3
jenkinsuser=$4
jenkinspasswd=$5
emailid=$6
jazzbuildmodule=$7

#create PROJECTS in BITBUCKET
java -jar $CLIENTJAR -s $BASEURL -u $bitbucketuser -p $bitbucketpasswd --action createProject --project "SLF"  --name "SLF" --description " created from cli" --private
java -jar $CLIENTJAR -s $BASEURL -u $bitbucketuser -p $bitbucketpasswd --action createProject --project "CAS"  --name "CAS" --description " created from cli" --private

# UPLOADS THE REPOSITORIES INTO BITBUCKET
./scripts/bitbucketpush.sh $BITBUCKETELB $bitbucketuser $bitbucketpasswd $emailid $jazzbuildmodule

#CALLS JENKINS JOB TO INSTALL Serverless application on AWS
#curl  http://$JENKINSELB:8080/job/inst_deploy_createservice/build?token=triggerCreateService --user jenkinsadmin:jenkinsadmin

#curl  -X GET -u $jenkinsuser:$jenkinspasswd http://$JENKINSELB/job/deploy-all-platform-services/buildWithParameters?token=dep-all-ps-71717&region=$region
