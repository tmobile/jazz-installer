#!/bin/bash
inst_stack_prefix=$1
jazz_admin=$2

#Modify platform_services config files
sed -i 's/"services_table": ".*.$/"services_table": "'$inst_stack_prefix'_services_dev",/g' ./jazz-core/platform_services/config/dev-config.json
sed -i 's/"services_table": ".*.$/"services_table": "'$inst_stack_prefix'_services_stg",/g' ./jazz-core/platform_services/config/stg-config.json
sed -i 's/"services_table": ".*.$/"services_table": "'$inst_stack_prefix'_services_prod",/g' ./jazz-core/platform_services/config/prod-config.json

sed -i 's/"admin_users": ".*.$/"admin_users": "'$jazz_admin'"/g' ./jazz-core/platform_services/config/dev-config.json
sed -i 's/"admin_users": ".*.$/"admin_users": "'$jazz_admin'"/g' ./jazz-core/platform_services/config/stg-config.json
sed -i 's/"admin_users": ".*.$/"admin_users": "'$jazz_admin'"/g' ./jazz-core/platform_services/config/prod-config.json
