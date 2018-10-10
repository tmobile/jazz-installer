#!/bin/bash
DEV_ID=$1
STG_ID=$2
PROD_ID=$3
jenkinsjsonpropsfile=$4
env_name_prefix=$5

sed -i "s/{AWS_DEV_API_ID_DEFAULT}/$DEV_ID/g" "$jenkinsjsonpropsfile"
sed -i "s/{AWS_STG_API_ID_DEFAULT}/$STG_ID/g" "$jenkinsjsonpropsfile"
sed -i "s/{AWS_STG_API_ID_JAZZ}/$STG_ID/g" "$jenkinsjsonpropsfile"
sed -i "s/{AWS_PROD_API_ID_JAZZ}/$PROD_ID/g" "$jenkinsjsonpropsfile"
sed -i "s/{AWS_PROD_API_ID_DEFAULT}/$PROD_ID/g" "$jenkinsjsonpropsfile"
sed -i "s/INSTANCE_PREFIX\".*.$/INSTANCE_PREFIX\": \"$env_name_prefix\",/g" "$jenkinsjsonpropsfile"
