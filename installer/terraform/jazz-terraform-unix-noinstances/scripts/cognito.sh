#!/bin/bash

POOL_NAME=$1
USER_POOL_ID=$2
CLIENT_ID=$3
POOL_USER_NAME=$4
POOL_USER_PASSWORD=$5

#Create a user
aws cognito-idp sign-up --client-id $CLIENT_ID --username $POOL_USER_NAME --password $POOL_USER_PASSWORD > $POOL_NAME-signup

username_rand=`cat $POOL_NAME-signup  | grep -i usersub | awk '{print $2}' |tr -d '",'`

#Auto verify the user
aws cognito-idp admin-confirm-sign-up  --user-pool-id $USER_POOL_ID --username $username_rand
