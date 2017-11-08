#!/bin/bash

POOL_NAME=$1
CLIENT_NAME=$2
POOL_USER_NAME=$3
POOL_USER_PASSWORD=$4
jenkinspropsfile=$5


#Create the userpool
aws cognito-idp create-user-pool --pool-name $POOL_NAME  --username-attributes email --schema '{"Name": "email", "AttributeDataType": "String", "Required": true}' --user-pool-tags Application=$POOL_NAME > /tmp/$POOL_NAME-user-pool
USER_POOL_ID=$(grep -E '"Id":' /tmp/$POOL_NAME-user-pool | awk -F'"' '{print $4}')
echo "Created User Pool: " $USER_POOL_ID

#Update Userpool with password policies
aws cognito-idp update-user-pool --user-pool-id $USER_POOL_ID --policies PasswordPolicy=\{MinimumLength=8,RequireUppercase=false,RequireLowercase=true,RequireNumbers=false,RequireSymbols=false\}

#Update the userpool with email verification information
aws cognito-idp update-user-pool --user-pool-id $USER_POOL_ID  --auto-verified-attributes email --verification-message-template '{"EmailSubjectByLink": "Jazz Notification - Account Verification", "EmailMessageByLink": "Hello,\n<br><br>\nThanks for signing up!\n<br><br>\nPlease click the link to verify your email address: {##Verify Email##}\n<br><br>\nTo know more about Jazz, please refer to link https://github.com/tmobile/jazz-core/wiki\n<br><br>\nBest,<br>\nJazz Team" , "DefaultEmailOption": "CONFIRM_WITH_LINK"}' > /tmp/$POOL_NAME-user-pool

#Update the custom attributes
aws cognito-idp add-custom-attributes --user-pool-id $USER_POOL_ID --custom-attributes '{"Name": "reg-code", "AttributeDataType": "String", "StringAttributeConstraints":{"MinLength": "1"}}'

#Create a userpool client
aws cognito-idp create-user-pool-client --user-pool-id $USER_POOL_ID --no-generate-secret --client-name $CLIENT_NAME > /tmp/$POOL_NAME-app-client
CLIENT_ID=$(grep -E '"ClientId":' /tmp/$POOL_NAME-app-client | awk -F'"' '{print $4}')
echo "Created App Client: " $CLIENT_ID



#Create a domain for the userpool
aws cognito-idp create-user-pool-domain --domain $POOL_NAME --user-pool-id $USER_POOL_ID

#Create a user
aws cognito-idp sign-up --client-id $CLIENT_ID --username $POOL_USER_NAME --password $POOL_USER_PASSWORD > /tmp/$POOL_NAME-signup

username_rand=`cat /tmp/$POOL_NAME-signup  | grep -i usersub | awk '{print $2}' |tr -d '",'`

#Auto verify the user
aws cognito-idp admin-confirm-sign-up  --user-pool-id $USER_POOL_ID --username $username_rand

# Adding Cognito Details to jenkinspropsfile
sed -i "s/USER_POOL_ID.*.$/USER_POOL_ID=$USER_POOL_ID/g" $jenkinspropsfile
sed -i "s/CLIENT_ID.*.$/CLIENT_ID=$CLIENT_ID/g" $jenkinspropsfile
