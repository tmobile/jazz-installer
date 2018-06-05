#!/bin/bash
SONAR_HOST_NAME=$1
jenkinsjsonpropsfile=$2

sed -i "s/{SONAR_HOST_NAME}/$SONAR_HOST_NAME/g" $jenkinsjsonpropsfile
