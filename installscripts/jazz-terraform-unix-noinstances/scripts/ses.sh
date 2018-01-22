#!/bin/bash
EMAIL_ADDRESS=$1
REGION=$2
JENKINSATTRIBSFILE=$3
AWS_ACCESS_KEY=$4
AWS_SECRET_KEY=$5
ENV_PREFIX=$6
POLICY_NAME="Policy-$ENV_PREFIX"
ACCOUNT=`aws sts get-caller-identity --output text --query 'Account'`
# Python Script create SMTP AUTH PASSWORD of the access key using the secret key
# the write to default.db in the cook book
python scripts/GetSESsmtpPassword.py $AWS_SECRET_KEY

# SES Validate and register email address
aws ses verify-email-identity --email-address $EMAIL_ADDRESS

# Attaching identity policy
aws ses put-identity-policy --identity $EMAIL_ADDRESS --policy-name $POLICY_NAME --policy '{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "stmt1510218035179",
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                    "arn:aws:iam::'$ACCOUNT':role/'$ENV_PREFIX'_lambda2_basic_execution_1",
                    "arn:aws:iam::'$ACCOUNT':root"
                ]
            },
            "Action": [
                "ses:SendEmail",
                "ses:SendRawEmail"
            ],
            "Resource": "arn:aws:ses:'$REGION':'$ACCOUNT':identity/'$EMAIL_ADDRESS'"
        }
    ]
}'

#Change the config values in JENKINSATTRIBSFILE
sed -i "s/default\['jenkins'\]\['SES-defaultSuffix'\].*.$/default['jenkins']['SES-defaultSuffix']='$EMAIL_ADDRESS'/g"  $JENKINSATTRIBSFILE

SMTP_HOST='email-smtp.'$REGION'.amazonaws.com'
sed -i "s/default\['jenkins'\]\['SES-smtpHost'\].*.$/default['jenkins']['SES-smtpHost']='$SMTP_HOST'/g"  $JENKINSATTRIBSFILE

sed -i "s/default\['jenkins'\]\['SES-smtpAuthUsername'\].*.$/default['jenkins']['SES-smtpAuthUsername']='$AWS_ACCESS_KEY'/g"  $JENKINSATTRIBSFILE
