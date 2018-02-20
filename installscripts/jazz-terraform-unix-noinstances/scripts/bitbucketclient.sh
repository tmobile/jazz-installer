#!/bin/bash
# This file creates CAS and SLF projects in bitbucket.
# Similar logic for gitlab is handled in launch_gitlab_docker.sh script.
sleep 60

#The below two variables are added from  configureJenkinselb.sh and configureBitbucketelb

BITBUCKETELB=jazz13-bitbucketelb-977486464.us-east-1.elb.amazonaws.com
BASEURL=http://$BITBUCKETELB
CLIENTJAR=~/atlassian-cli-6.7.1/lib/bitbucket-cli-6.7.0.jar
bitbucketuser=$1
bitbucketpasswd=$2

#create PROJECTS in BITBUCKET
java -jar $CLIENTJAR -s $BASEURL -u $bitbucketuser -p $bitbucketpasswd --action createProject --project "SLF"  --name "SLF" --description " created from cli" --private
java -jar $CLIENTJAR -s $BASEURL -u $bitbucketuser -p $bitbucketpasswd --action createProject --project "CAS"  --name "CAS" --description " created from cli" --private
