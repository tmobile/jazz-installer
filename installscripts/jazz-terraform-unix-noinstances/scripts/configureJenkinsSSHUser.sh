#!/bin/bash

JENKINS_SSH_USER=$1
JENKINSATTRIBSFILE=$2
JENKINS_CLIENT_RB=$3

sed -i "s/default\['jenkins'\]\['SSH_user'\].*.$/default['jenkins']['SSH_user']='$JENKINS_SSH_USER'/g"  $JENKINSATTRIBSFILE
sed -i "s/root=.*.$/root='\/home\/$JENKINS_SSH_USER'/g" $JENKINS_CLIENT_RB
