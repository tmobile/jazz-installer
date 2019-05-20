#!/bin/sh
JENKINS_CLI_CMD=$1
CREDENTIAL_ID=$2
ACCESSKEY=$3
SECRETKEY=$4


cat <<EOF | $JENKINS_CLI_CMD create-credentials-by-xml system::system::jenkins "(global)"
<com.cloudbees.jenkins.plugins.awscredentials.AWSCredentialsImpl plugin="aws-credentials@1.21">
  <scope>GLOBAL</scope>
  <id>$CREDENTIAL_ID</id>
  <description>AWS Credentials</description>
  <accessKey>$ACCESSKEY</accessKey>
  <secretKey>$SECRETKEY</secretKey>
  <iamRoleArn></iamRoleArn>
  <iamMfaSerialNumber></iamMfaSerialNumber>
</com.cloudbees.jenkins.plugins.awscredentials.AWSCredentialsImpl>
EOF
