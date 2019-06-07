#!/bin/sh
JENKINS_CLI_CMD=$1
CREDENTIAL_ID=$2
USERNAME=$3
PASSWORD=$4

cat <<EOF | $JENKINS_CLI_CMD create-credentials-by-xml system::system::jenkins "(global)"
<com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>
  <scope>GLOBAL</scope>
  <id>$CREDENTIAL_ID</id>
  <description>APIGEE Credentials</description>
  <username>$USERNAME</username>
  <password>$PASSWORD</password>
</com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>
EOF
