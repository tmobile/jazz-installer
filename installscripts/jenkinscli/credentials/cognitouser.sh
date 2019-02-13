#!/bin/sh

JENKINS_CLI_CMD=$1
COGNITOUSER=$2
COGNITOPASSWORD=$3

cat <<EOF | $JENKINS_CLI_CMD create-credentials-by-xml system::system::jenkins "(global)"
<com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>
  <scope>GLOBAL</scope>
  <id>SVC_ADMIN</id>
  <description>Jazz Admin User</description>
  <username>$COGNITOUSER</username>
  <password>$COGNITOPASSWORD</password>
</com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>
EOF
