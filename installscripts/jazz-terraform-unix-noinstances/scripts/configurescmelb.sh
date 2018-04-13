#!/bin/bash

scmbb=$1
bitbucketelbdnsname=$2
jenkinsattribsfile=$3
jenkinsjsonpropertiesfile=$4
bitbucketclient=$5

#proceeding
if [ "$scmbb" == 1 ]
then
    sed -i "s/default\['scmelb'\].*.$/default['scmelb']='$bitbucketelbdnsname'/g"  $jenkinsattribsfile
    sed -i "s/BASE_URL\".*.$/BASE_URL\": \"$bitbucketelbdnsname\",/g" $jenkinsjsonpropertiesfile
    # sed -i "s/BITBUCKETELB=.*.$/BITBUCKETELB=$bitbucketelbdnsname/g" $bitbucketclient
fi

#ModifyCodebase is moved to ../scripts/configureJazzCore.sh file
