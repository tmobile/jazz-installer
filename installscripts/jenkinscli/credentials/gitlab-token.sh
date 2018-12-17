#!/bin/sh

JENKINS_CLI_CMD=$1
GITLAB_TOKEN=$2

cat <<EOF | $JENKINS_CLI_CMD create-credentials-by-xml system::system::jenkins "(global)"
        <com.dabsquared.gitlabjenkins.connection.GitLabApiTokenImpl plugin="gitlab-plugin@1.5.2">
          <scope>GLOBAL</scope>
          <id>Jazz-Gitlab-API-Cred</id>
          <description>Jazz-Gitlab-API-Cred</description>
          <apiToken>$GITLAB_TOKEN</apiToken>
        </com.dabsquared.gitlabjenkins.connection.GitLabApiTokenImpl>
EOF
