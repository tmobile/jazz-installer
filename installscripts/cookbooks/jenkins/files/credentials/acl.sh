#!/bin/sh

JENKINS_CLI_CMD=$1
ACLUSER=$2
ACLPASSWORD=$3

cat <<EOF | $JENKINS_CLI_CMD create-credentials-by-xml system::system::jenkins "(global)"
<com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>
  <scope>GLOBAL</scope>
  <id>ACL_CRDENTIAL</id>
  <description>ACL CREDENTIALS</description>
  <username>$ACLUSER</username>
  <password>$ACLPASSWORD</password>
</com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>
EOF
