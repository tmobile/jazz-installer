#!/bin/bash
# This file creates CAS and SLF projects in bitbucket.
# The corresponding projects creation in gitlab is handled in launch_gitlab_docker.sh script.
sleep 60

#The below variable is added from configureJenkinselb.sh and configureBitbucketelb
bitbucketuser=$1
bitbucketpasswd=$2
bitbucketelb=$3

BASEURL=http://$bitbucketelb
CLIENTJAR=~/atlassian-cli-6.7.1/lib/bitbucket-cli-6.7.0.jar

#create PROJECTS in BITBUCKET
java -jar $CLIENTJAR -s $BASEURL -u $bitbucketuser -p $bitbucketpasswd --action createProject --project "SLF"  --name "SLF" --description " created from cli" --private
java -jar $CLIENTJAR -s $BASEURL -u $bitbucketuser -p $bitbucketpasswd --action createProject --project "CAS"  --name "CAS" --description " created from cli" --private
