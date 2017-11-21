#Adding s3-api-doc bucket name
s3_api_doc_name=$1

sed -i 's/{api_doc_name}/'$s3_api_doc_name'/g' ./jazz-core/jazz-web/config/config.json
sed -i 's/{api_doc_name}/'$s3_api_doc_name'/g' ./jazz-core/jazz-web/config/config.prod.json
