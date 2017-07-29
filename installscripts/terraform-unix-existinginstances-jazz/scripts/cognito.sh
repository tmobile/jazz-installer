#!/bin/bash

POOL_NAME=$1
CLIENT_NAME=$2
POOL_USER_NAME=$3
POOL_USER_PASSWORD=$4
jenkinspropsfile=$5

# Create User Pool
aws cognito-idp create-user-pool --pool-name $POOL_NAME --auto-verified-attributes email > /tmp/$POOL_NAME-user-pool
USER_POOL_ID=$(grep -E '"Id":' /tmp/$POOL_NAME-user-pool | awk -F'"' '{print $4}')
echo "Created User Pool " $USER_POOL_ID

# Create the App Client
aws cognito-idp create-user-pool-client --user-pool-id $USER_POOL_ID --no-generate-secret --client-name $CLIENT_NAME > /tmp/$POOL_NAME-app-client
CLIENT_ID=$(grep -E '"ClientId":' /tmp/$POOL_NAME-app-client | awk -F'"' '{print $4}')
echo "Created App Client " $CLIENT_ID

# Create User
aws cognito-idp sign-up --client-id $CLIENT_ID --username $POOL_USER_NAME --password $POOL_USER_PASSWORD > /dev/null 2>&1

# Confirm User Registration
aws cognito-idp admin-confirm-sign-up  --user-pool-id $USER_POOL_ID --username $POOL_USER_NAME

# Adding Cognito Details to jenkinspropsfile
sed -i "s/USER_POOL_ID=.*.$/USER_POOL_ID=$USER_POOL_ID/g" $jenkinspropsfile
sed -i "s/CLIENT_ID=.*.$/CLIENT_ID=$CLIENT_ID/g" $jenkinspropsfile

