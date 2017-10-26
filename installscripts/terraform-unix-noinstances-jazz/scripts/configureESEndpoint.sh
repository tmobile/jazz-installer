ES_ENDPOINT=$1
JENKINSELB=$2
region=$3
sed -i "s/{inst_elastic_search_hostname}/$ES_ENDPOINT/g " ./jazz-core/cloud-logs-streamer/index.js
# this is done in bitbucketclient.sh since that is last script to run in this demo with existing instances
#curl  -X GET -u jenkinsadmin:jenkinsadmin http://$JENKINSELB:8080/job/deploy-all-platform-services/buildWithParameters?token=dep-all-ps-71717&region=$region

# Add permission to Lambda function
#aws lambda add-permission \
#--function-name arn:aws:lambda:us-east-1:682452625784:function:cloud-logs-streamer-dev \
#--statement-id lambdaFxnPermission \
#--action lambda:* \
#--principal logs.$region.amazonaws.com

#Sleeping for policies to be applied
sleep 120
# Configure ElasticSearch Template via json

curl -X POST --url https://$ES_ENDPOINT/_template/apilogs  --data-binary @./jazz-core/cloud-logs-streamer/_ES/apilogs.json --header "Content-Type: application/json"

curl -X POST --url https://$ES_ENDPOINT/_template/applicationlogs  --data-binary @./jazz-core/cloud-logs-streamer/_ES/applicationlogs.json --header "Content-Type: application/json"

curl -XPUT https://$ES_ENDPOINT/apilogs?pretty --data-binary @./jazz-core/cloud-logs-streamer/_ES/apilogs.json --header "Content-Type: application/json"

curl -XPUT https://$ES_ENDPOINT/applicationlogs?pretty --data-binary @./jazz-core/cloud-logs-streamer/_ES/applicationlogs.json --header "Content-Type: application/json"