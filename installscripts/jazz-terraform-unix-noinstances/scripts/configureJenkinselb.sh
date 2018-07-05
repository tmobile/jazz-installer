#!/bin/bash

JENKINSELB=$1
jenkinsattribsfile=$2

sed -i "s/default\['jenkinselb'\].*.$/default['jenkinselb']='$JENKINSELB'/g"  $jenkinsattribsfile