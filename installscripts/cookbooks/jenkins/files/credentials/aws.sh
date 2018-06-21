JENKINS_URL=http://$1/ # localhost or jenkins elb url
JENKINS_CLI=$2
AUTHFILE=$3

echo "$0 $1 $2 $3"

AWS_ACCESS_KEY="Replaced with sed command from create.sh"
AWS_SECRET_KEY="Replaced with sed command from create.sh"

cat <<EOF | java -jar $JENKINS_CLI -s $JENKINS_URL -auth @$AUTHFILE create-credentials-by-xml system::system::jenkins "(global)"
<com.cloudbees.jenkins.plugins.awscredentials.AWSCredentialsImpl plugin="aws-credentials@1.21">
  <scope>GLOBAL</scope>
  <id>awscreds1</id>
  <description>AWS Credentials</description>
  <accessKey>$AWS_ACCESS_KEY</accessKey>
  <secretKey>$AWS_SECRET_KEY</secretKey>
  <iamRoleArn></iamRoleArn>
  <iamMfaSerialNumber></iamMfaSerialNumber>
</com.cloudbees.jenkins.plugins.awscredentials.AWSCredentialsImpl>
EOF
