#!/bin/sh
JENKINS_CLI_CMD=$1
CREDENTIAL_ID=$2
ACCESSKEY=$3
SECRETKEY=$4

cat <<EOF | $JENKINS_CLI_CMD create-credentials-by-xml system::system::jenkins "(global)"
<com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>
  <scope>GLOBAL</scope>
  <id>$CREDENTIAL_ID</id>
  <description>user created on bitbucket</description>
  <username>$ACCESSKEY</username>
  <password>$SECRETKEY</password>
</com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>
EOF
