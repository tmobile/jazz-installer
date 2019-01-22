#!/bin/bash

eval "$(jq -r '@sh "export PASSWD=\(.passwd) IP=\(.ip) GITLAB_ADMIN=\(.gitlab_admin)"')"
token=$( python "$JAZZ_INSTALLER_ROOT"/installscripts/jazz-terraform-unix-noinstances/scripts/privatetoken.py mytoken "${PASSWD}" "http://${IP}")
ip=${IP}
scm_username=${GITLAB_ADMIN}
# shellcheck disable=SC2086
# shellcheck disable=SC2091
$(curl -H "Content-Type: application/json" --header "PRIVATE-TOKEN: $token" -X PUT "http://$ip/api/v4/users/1" -d '{"username":"'''$scm_username'''"}')
# shellcheck disable=SC2091
$(curl -H "Content-Type: application/json" --header "PRIVATE-TOKEN: $token" -X POST "http://$ip/api/v4/groups" -d '{"name":"SLF","path":"slf", "description": "Jazz framework, templates and services"}')
# shellcheck disable=SC2091
$(curl -H "Content-Type: application/json" --header "PRIVATE-TOKEN: $token" -X POST "http://$ip/api/v4/groups" -d '{"name":"CAS","path":"cas", "description": "User created services repository"}')
ns_id_slf=$(curl -sL --header "PRIVATE-TOKEN: $token" -X GET "http://$ip/api/v4/groups/slf" | awk -F',' '{print $1}' | awk -F':' '{print $2}')
ns_id_cas=$(curl -sL --header "PRIVATE-TOKEN: $token" -X GET "http://$ip/api/v4/groups/cas" | awk -F',' '{print $1}' | awk -F':' '{print $2}')

jq -n \
    --arg token "$token" \
    --arg scm_slfid "$ns_id_slf" \
    '{"token", $token,"scm_slfid", $scm_slfid}'

# Replacing Gitlab IP in default.rb file of Jenkins cookbook
attrbsfile=$JAZZ_INSTALLER_ROOT/installscripts/cookbooks/jenkins/attributes/default.rb
sed -i "s|default\['scm'\].*.|default\['scm'\]='gitlab'|g" "$attrbsfile"
sed -i "s|default\['scmelb'\].*.|default\['scmelb'\]='$ip'|g" "$attrbsfile"
sed -i "s|default\['scmpath'\].*.|default\['scmpath'\]='$ip'|g" "$attrbsfile"
sed -i "s|default\['gitlabtoken'\].*.|default\['gitlabtoken'\]='$token'|g" "$attrbsfile"

#Populating Gitlab config in Jenkins json file
jenkinsJsonfile=$JAZZ_INSTALLER_ROOT/installscripts/cookbooks/jenkins/files/default/jazz-installer-vars.json
sed -i "s/TYPE\".*.$/TYPE\": \"gitlab\",/g" "$jenkinsJsonfile"
sed -i "s/PRIVATE_TOKEN\".*.$/PRIVATE_TOKEN\": \"$token\",/g" "$jenkinsJsonfile"
sed -i "s/CAS_NAMESPACE_ID\".*.$/CAS_NAMESPACE_ID\": \"$ns_id_cas\"/g" "$jenkinsJsonfile"
sed -i "s|BASE_URL\".*.$|BASE_URL\": \"$ip\",|g" "$jenkinsJsonfile"
