#!/bin/sh

JENKINS_CLI_CMD=$1
AWS_ACCESS_KEY=$2
AWS_SECRET_KEY=$3

cat <<EOF | $JENKINS_CLI_CMD create-credentials-by-xml system::system::jenkins "(global)"
<com.cloudbees.jenkins.plugins.awscredentials.AWSCredentialsImpl plugin="aws-credentials@1.21">
  <scope>GLOBAL</scope>
  <id>jazz_awscreds</id>
  <description>AWS Credentials</description>
  <accessKey>$AWS_ACCESS_KEY</accessKey>
  <secretKey>$AWS_SECRET_KEY</secretKey>
  <iamRoleArn></iamRoleArn>
  <iamMfaSerialNumber></iamMfaSerialNumber>
</com.cloudbees.jenkins.plugins.awscredentials.AWSCredentialsImpl>
EOF
