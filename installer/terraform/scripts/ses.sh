#!/bin/sh
EMAIL_ADDRESS=$1
REGION=$2
ENV_PREFIX=$3
POLICY_NAME="Policy-$ENV_PREFIX"
ACCOUNT=$(aws sts get-caller-identity --output text --query 'Account')

# SES Validate and register email address
aws ses verify-email-identity --email-address "$EMAIL_ADDRESS"

# Attaching identity policy
# We have to do this here because terraform doesn't yet support this specific operation
# shellcheck disable=SC2086
aws ses put-identity-policy --identity "$EMAIL_ADDRESS" --policy-name "$POLICY_NAME" --policy '{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "stmt1510218035179",
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                    "arn:aws:iam::'$ACCOUNT':role/'$ENV_PREFIX'_platform_services",
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
