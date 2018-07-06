#!/bin/bash
DOCKERJENKINS=$1
ATTRIBUTEFILE=$2
if [ $DOCKERJENKINS == 1 -o $DOCKERJENKINS == true ]; then
  JENKINS_CONTAINER=/var/jenkins_home
  sed -i "s|default\['jenkins'\]\['home'\].*.$|default['jenkins']['home']='$JENKINS_CONTAINER'|g"  $ATTRIBUTEFILE
  sed -i "s|default\['scenario'\].*.$|default['scenario']='scenario2or3'|g"  $ATTRIBUTEFILE
fi
