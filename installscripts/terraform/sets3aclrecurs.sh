#!/bin/bash
BUCKET_NAME=%1
PROJECT_FOLDER=%2
cd $PROJECT_FOLDER


find . \( \! -name "." -o -name ".." \) -print | sed 's/^.\///g'
for key in $( find . \( \! -name "." -o -name ".." \) -print | sed 's/^.\///g' ); do
    echo item: $key
	 aws s3api put-object-acl --bucket $BUCKET_NAME --key $key --grant-full-control id=78d7d8174c655d51683784593fe4e6f74a7ed3fae3127d2beca2ad39e4fdc79a,uri=http://acs.amazonaws.com/groups/s3/LogDelivery,uri=http://acs.amazonaws.com/groups/global/AuthenticatedUsers --grant-read uri=http://acs.amazonaws.com/groups/global/AllUsers   --grant-read-acp uri=http://acs.amazonaws.com/groups/global/AllUsers 
done
cd -
