#!/bin/bash
SONAR_HOST_NAME=$1
if [ $2 == "1" -o $2 == 1 ]; then
  ENABLE_SONAR="true"
else
  ENABLE_SONAR="false"
fi
jenkinsjsonpropsfile=$3

sed -i "s/{SONAR_HOST_NAME}/$SONAR_HOST_NAME/g" $jenkinsjsonpropsfile
sed -i "s/{ENABLE_SONAR}/$ENABLE_SONAR/g" $jenkinsjsonpropsfile
sed -i "s/{ENABLE_VULNERABILITY_SCAN}/$ENABLE_SONAR/g" $jenkinsjsonpropsfile
