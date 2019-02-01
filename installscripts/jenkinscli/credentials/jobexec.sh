#!/bin/sh

JENKINS_CLI_CMD=$1

cat <<EOF | $JENKINS_CLI_CMD create-credentials-by-xml system::system::jenkins "(global)"
<com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>
  <scope>GLOBAL</scope>
  <id>jobexecutor</id>
  <description>user created on bitbucket</description>
  <username>jobexec</username>
  <password>jenkinsadmin</password>
</com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>
EOF
