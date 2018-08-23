ES_ENDPOINT=$1
JENKINSELB=$2
region=$3
sed -i "s/{inst_elastic_search_hostname}/$ES_ENDPOINT/g " ./jazz-core/core/jazz_cloud-logs-streamer/index.js
# this is done in bitbucketclient.sh since that is last script to run in this demo with existing instances

# Add permission to Lambda function
#aws lambda add-permission \
#--function-name arn:aws:lambda:us-east-1:682452625784:function:cloud-logs-streamer-dev \
#--statement-id lambdaFxnPermission \
#--action lambda:* \
#--principal logs.$region.amazonaws.com

#Sleeping for policies to be applied
sleep 120
# Configure ElasticSearch Template via json

curl -X POST --url https://$ES_ENDPOINT/_template/apilogs  --data-binary @./jazz-core/core/jazz_cloud-logs-streamer/_ES/apilogs.json --header "Content-Type: application/json"

curl -X POST --url https://$ES_ENDPOINT/_template/applicationlogs  --data-binary @./jazz-core/core/jazz_cloud-logs-streamer/_ES/applicationlogs.json --header "Content-Type: application/json"

curl -XPUT https://$ES_ENDPOINT/apilogs?pretty --data-binary @./jazz-core/core/jazz_cloud-logs-streamer/_ES/apilogs.json --header "Content-Type: application/json"

curl -XPUT https://$ES_ENDPOINT/applicationlogs?pretty --data-binary @./jazz-core/core/jazz_cloud-logs-streamer/_ES/applicationlogs.json --header "Content-Type: application/json"

# Adding index-pattern in kibana
curl_params="--include --silent --retry 5 --retry-delay 3  --output /dev/null"
ES_version=`curl -s  https://$ES_ENDPOINT | grep number | awk '{print $3}'| tr -d ',"'`

echo "Creating index patterns..."
index_pattern_apilogs="https://$ES_ENDPOINT/.kibana/index-pattern/apilogs"
curl $curl_params -X POST "${index_pattern_apilogs}" -d '{"title":"apilogs","timeFieldName":"@timestamp","customFormats":"{}"}'
index_pattern_applicationlogs="https://$ES_ENDPOINT/.kibana/index-pattern/applicationlogs"
curl $curl_params -X POST "${index_pattern_applicationlogs}" -d '{"title":"applicationlogs","timeFieldName":"@timestamp","customFormats":"{}"}'

echo "Creating default index..."
config_url="https://$ES_ENDPOINT/.kibana/config/$ES_version"
curl $curl_params -X POST "${config_url}" -d '{"defaultIndex":"applicationlogs"}'
