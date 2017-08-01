#!/bin/bash

jazz_bucket_dev=$1
jazz_bucket_stg=$2
jazz_bucket_prod=$3
jazz-bucket_cloudfrontlogs=$4
jazz_bucket_web=$5
jenkinspropsfile=$6

echo $1
echo $2
echo $3
echo $4
echo $5

# new changes for randomizing s3 bucket names
sed -i "s/jazz_bucket_dev.*.$/jazz_bucket_dev=$jazz_bucket_dev/g" $jenkinspropsfile
sed -i "s/jazz_bucket_stg.*.$/jazz_bucket_stg=$jazz_bucket_stg/g" $jenkinspropsfile
sed -i "s/jazz_bucket_prod.*.$/jazz_bucket_prod=$jazz_bucket_prod/g" $jenkinspropsfile
sed -i "s/jazz_bucket_cloudfrontlogs.*.$/jazz_bucket_cloudfrontlogs=$jazz_bucket_cloudfrontlogs/g" $jenkinspropsfile
sed -i "s/jazz_bucket_web.*.$/jazz_bucket_web=$jazz_bucket_web/g" $jenkinspropsfile

