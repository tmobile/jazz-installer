#!/bin/sh

JENKINS_CLI_CMD=$1
GITLAB_USER=$2
GITLAB_PASSWORD=$3

cat <<EOF | $JENKINS_CLI_CMD create-credentials-by-xml system::system::jenkins "(global)"
<com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>
  <scope>GLOBAL</scope>
  <id>jazz_repocreds</id>
  <description>Gitlab user</description>
  <username>$GITLAB_USER</username>
  <password>$GITLAB_PASSWORD</password>
</com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>
EOF
