#!/bin/bash

POOL_NAME=$1
# List Users Pools
aws cognito-idp list-user-pools --max-results 60  > /tmp/poollist

USER_POOL_ID=`grep -B1 $POOL_NAME /tmp/poollist  | grep Id | awk -F':' '{print $2}'| tr -d '",'`

# Delete User Pool
# Delete domain before deleting user pool
for i in $USER_POOL_ID
do
    aws cognito-idp delete-user-pool-domain --domain $POOL_NAME --user-pool-id $USER_POOL_ID
    aws cognito-idp delete-user-pool --user-pool-id $i
done
