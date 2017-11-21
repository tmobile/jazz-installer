#!/bin/bash

BUCKET_NAME=$1
CANONICAL_ID=$2
aws s3api put-bucket-acl --bucket $BUCKET_NAME --grant-full-control id=$CANONICAL_ID,uri=http://acs.amazonaws.com/groups/s3/LogDelivery
