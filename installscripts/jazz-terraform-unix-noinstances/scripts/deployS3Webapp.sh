#!/bin/bash
BUCKET_NAME=$1
REGION=$2
CANONICAL_ID=$3

aws s3 cp jazz-core/core/jazz-web s3://"$BUCKET_NAME" --recursive --region "$REGION"

for key in $( find jazz-core/core/jazz-web \( -not -type d \) -print | sed "s|jazz-core/core/jazz-web/||" ); do
    echo item: "$key"
         aws s3api put-object-acl --bucket "$BUCKET_NAME" --key "$key" --grant-full-control id="$CANONICAL_ID",uri=http://acs.amazonaws.com/groups/s3/LogDelivery
done
