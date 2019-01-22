#!/bin/sh

JENKINS_CLI_CMD=$1
SONARUSER=$2
SONARPASSWORD=$3

cat <<EOF | $JENKINS_CLI_CMD create-credentials-by-xml system::system::jenkins "(global)"
<com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>
  <scope>GLOBAL</scope>
  <id>SONAR_ADMIN_CREDENTIAL</id>
  <description>SONAR CREDENTIALS</description>
  <username>$SONARUSER</username>
  <password>$SONARPASSWORD</password>
</com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>
EOF
