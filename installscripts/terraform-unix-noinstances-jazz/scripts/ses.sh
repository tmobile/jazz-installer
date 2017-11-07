#!/bin/bash
EMAIL_ADDRESS=$1
REGION=$2
JENKINSATTRIBSFILE=$3
AWS_ACCESS_KEY=$4
AWS_SECRET_KEY=$5

# Python Script to get the SMTP PASSWORD of the access key using the secret key
python scripts/GetSESsmtpPassword.py $AWS_SECRET_KEY

# SES Validate and register email address
aws ses verify-email-identity --email-address $EMAIL_ADDRESS

#Change the config values in JENKINSATTRIBSFILE

#<defaultSuffix>serverless@t-mobile.com</defaultSuffix>
sed -i "s/default\['jenkins'\]\['SES-defaultSuffix'\].*.$/default['jenkins']['SES-defaultSuffix']='$EMAIL_ADDRESS'/g"  $JENKINSATTRIBSFILE

#<smtpHost>email-smtp.us-east-1.amazonaws.com</smtpHost>
SMTP_HOST = 'email-smtp.'$REGION'.amazonaws.com'
sed -i "s/default\['jenkins'\]\['SES-smtpHost'\].*.$/default['jenkins']['SES-smtpHost']='$SMTP_HOST'/g"  $JENKINSATTRIBSFILE

# <smtpAuthUsername>AKIAI4IYTDWX3W5QHHTA</smtpAuthUsername>
sed -i "s/default\['jenkins'\]\['SES-smtpAuthUsername'\].*.$/default['jenkins']['SES-smtpAuthUsername']='$AWS_ACCESS_KEY'/g"  $JENKINSATTRIBSFILE

#<smtpAuthPassword>{AQAAABAAAAAgMJG+jzUclj0Vh82W7VlOI5YbGwNNmt3Q2po+dkId9xMHWyoXLqCo5wkp+ddwNdeN}</smtpAuthPassword>  
read -r SMTP_AUTH_PASSWORD<smtppassword.txt
sed -i "s/default\['jenkins'\]\['SES-smtpAuthUsername'\].*.$/default['jenkins']['SES-smtpAuthUsername']='$SMTP_AUTH_PASSWORD'/g"  $JENKINSATTRIBSFILE











