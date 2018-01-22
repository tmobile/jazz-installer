#!/bin/bash
scmbb=$1
bitbucketelbdnsname=$2
jenkinsattribsfile=$3
jenkinspropertiesfile=$4
jenkinsjsonpropertiesfile=$5
bitbucketclient=$6
inst_stack_prefix=$7
jazz_admin=$8

#proceeding
if [ "$scmbb" == 1 ]
then
    sed -i "s/default\['scmelb'\].*.$/default['scmelb']='$bitbucketelbdnsname'/g"  $jenkinsattribsfile
    sed -i "s/REPO_BASE=.*.$/REPO_BASE=$bitbucketelbdnsname/g" $jenkinspropertiesfile
    sed -i "s/REPO_BASE\".*.$/REPO_BASE\": \"$bitbucketelbdnsname\",/g" $jenkinsjsonpropertiesfile
    sed -i "s/BITBUCKETELB=.*.$/BITBUCKETELB=$bitbucketelbdnsname/g" $bitbucketclient
fi

