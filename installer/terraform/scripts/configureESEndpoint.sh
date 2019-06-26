#!/bin/sh

# TODO This should be in Python + drop curl dep

ES_ENDPOINT=$1
KIBANA_ENDPOINT=$2
sed -i "s#{inst_elastic_search_hostname}#$ES_ENDPOINT#g " ./jazz-core/core/jazz_cloud-logs-streamer/index.js
# this is done in bitbucketclient.sh since that is last script to run in this demo with existing instances

# Add permission to Lambda function
#aws lambda add-permission \
#--function-name arn:aws:lambda:us-east-1:682452625784:function:cloud-logs-streamer-dev \
#--statement-id lambdaFxnPermission \
#--action lambda:* \
#--principal logs.$region.amazonaws.com

#Sleeping for policies to be applied
#sleep 120
# Configure ElasticSearch Template via json

curl -X POST --url "$ES_ENDPOINT/_template/apilogs"  --data-binary @./jazz-core/core/jazz_cloud-logs-streamer/_ES/apilogs.json --header "Content-Type: application/json"

curl -X POST --url "$ES_ENDPOINT/_template/applicationlogs"  --data-binary @./jazz-core/core/jazz_cloud-logs-streamer/_ES/applicationlogs.json --header "Content-Type: application/json"

curl -XPUT "$ES_ENDPOINT/apilogs?pretty" --data-binary @./jazz-core/core/jazz_cloud-logs-streamer/_ES/apilogs.json --header "Content-Type: application/json"

curl -XPUT "$ES_ENDPOINT/applicationlogs?pretty" --data-binary @./jazz-core/core/jazz_cloud-logs-streamer/_ES/applicationlogs.json --header "Content-Type: application/json"

echo "Creating index patterns..."
index_pattern_applicationlogs="$KIBANA_ENDPOINT/api/saved_objects/index-pattern/applicationlogs"
curl --include --silent --retry 5 --retry-delay 3 --output /dev/null -X POST "$index_pattern_applicationlogs" -H 'kbn-xsrf: true' -H 'Content-Type: application/json' -d '{
  "attributes": {"title":"applicationlogs","timeFieldName":"timestamp"}
}'
index_pattern_apilogs="$KIBANA_ENDPOINT/api/saved_objects/index-pattern/apilogs"
curl --include --silent --retry 5 --retry-delay 3 --output /dev/null -X POST "$index_pattern_apilogs" -H 'kbn-xsrf: true' -H 'Content-Type: application/json' -d '
{
  "attributes": {"title":"apilogs","timeFieldName":"timestamp"}
}'

echo "Default Index"
config_url="$KIBANA_ENDPOINT/api/kibana/settings"
curl --include --silent --retry 5 --retry-delay 3 --output /dev/null -X POST "$config_url" -H 'kbn-xsrf: true' -H 'Content-Type: application/json' -d '
{
  "changes": {"defaultIndex":"applicationlogs"}
}'
