#!/bin/bash

JENKINSATTRIBSFILE=$1

sed -i "s/default\['jenkins'\]\['SSH_user'\].*.$/default['jenkins']['SSH_user']='$JENKINS_SSH_USER'/g"  $JENKINSATTRIBSFILE
