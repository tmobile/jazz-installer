#!/bin/sh

JENKINS_CLI_CMD=$1
ACL_DB_USER=$2
ACL_DB_PASSWORD=$3

cat <<EOF | $JENKINS_CLI_CMD create-credentials-by-xml system::system::jenkins "(global)"
<com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>
  <scope>GLOBAL</scope>
  <id>ACL_DB_CRDENTIAL</id>
  <description>ACL CREDENTIALS</description>
  <username>$ACL_DB_USER</username>
  <password>$ACL_DB_PASSWORD</password>
</com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>
EOF
