#!/bin/sh

JENKINS_CLI_CMD=$1
BBUSER=$2
BBPASSWORD=$3

cat <<EOF | $JENKINS_CLI_CMD create-credentials-by-xml system::system::jenkins "(global)"
<com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>
  <scope>GLOBAL</scope>
  <id>jazz_repocreds</id>
  <description>user created on bitbucket</description>
  <username>$BBUSER</username>
  <password>$BBPASSWORD</password>
</com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>
EOF
