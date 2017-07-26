set aws_api_gateway_rest_api_id=%1
set region=%2
set jenkinspropsfile=%3
sed -i 's/API_KEY=.*.$/API_KEY=%aws_api_gateway_rest_api_id%/g' %jenkinspropsfile%
sed -i 's/{inst_API_KEY\}/%aws_api_gateway_rest_api_id%/g' ./jazz-core/cloud-api-onboarding-website/app/scripts/script.js
sed -i 's/{inst_region}/%region%/g' ./jazz-core/cloud-api-onboarding-website/app/scripts/script.js

