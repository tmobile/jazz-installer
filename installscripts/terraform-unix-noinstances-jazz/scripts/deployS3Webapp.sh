BUCKET_NAME=$1
REGION=$2
CANONICAL_ID=$3
cd ./jazz-core/jazz-web
aws s3 cp . s3://$BUCKET_NAME  --recursive --region $REGION

IFS=$(echo -en "\n\b")
for key in $( find . \( -not -type d \) -print | sed 's/^.\///g' ); do
    echo item: $key
         aws s3api put-object-acl --bucket $BUCKET_NAME --key $key --grant-full-control id=$CANONICAL_ID,uri=http://acs.amazonaws.com/groups/s3/LogDelivery,uri=http://acs.amazonaws.com/groups/global/AuthenticatedUsers --grant-read uri=http://acs.amazonaws.com/groups/global/AllUsers   --grant-read-acp uri=http://acs.amazonaws.com/groups/global/AllUsers
done
cd -



