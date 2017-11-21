#!/bin/bash

POOL_NAME=$1
# List Users Pools
aws cognito-idp list-user-pools --max-results 60  > /tmp/poollist

USER_POOL_ID=`jq '.UserPools[] | if .Name == "'$POOL_NAME'" then .Id else empty end' < /tmp/poollist |tr -d '"'`

# Delete domain before deleting user pool
aws cognito-idp delete-user-pool-domain --domain $POOL_NAME --user-pool-id $USER_POOL_ID

# Delete User Pool
for i in $USER_POOL_ID
do
        aws cognito-idp delete-user-pool --user-pool-id $i
done
