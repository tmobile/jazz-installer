#!/bin/bash
EMAIL_ADDRESS=$1
REGION=$2
JENKINSATTRIBSFILE=$3
AWS_ACCESS_KEY=$4
AWS_SECRET_KEY=$5

# Python Script create SMTP AUTH PASSWORD of the access key using the secret key
# the write to default.db in the cook book
python scripts/GetSESsmtpPassword.py $AWS_SECRET_KEY

# SES Validate and register email address
aws ses verify-email-identity --email-address $EMAIL_ADDRESS

#Change the config values in JENKINSATTRIBSFILE
sed -i "s/default\['jenkins'\]\['SES-defaultSuffix'\].*.$/default['jenkins']['SES-defaultSuffix']='$EMAIL_ADDRESS'/g"  $JENKINSATTRIBSFILE

SMTP_HOST='email-smtp.'$REGION'.amazonaws.com'
sed -i "s/default\['jenkins'\]\['SES-smtpHost'\].*.$/default['jenkins']['SES-smtpHost']='$SMTP_HOST'/g"  $JENKINSATTRIBSFILE

sed -i "s/default\['jenkins'\]\['SES-smtpAuthUsername'\].*.$/default['jenkins']['SES-smtpAuthUsername']='$AWS_ACCESS_KEY'/g"  $JENKINSATTRIBSFILE


