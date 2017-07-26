JENKINS_URL=http://$1:8080/ # localhost or jenkins elb url
AUTHFILE=/home/ec2-user/cookbooks/jenkins/files/default/authfile
JENKINS_CLI=/home/ec2-user/jenkins-cli.jar
AWS_ACCESS_KEY=AKIAJ24MZSJQ7SYWXUNA
AWS_SECRET_KEY=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
echo "$0 $1"
#cat <<EOF | java -jar $JENKINS_CLI -s $JENKINS_URL -auth @$AUTHFILE update-credentials-by-xml system::system::jenkins "(global)" 2c88b8e9-52f7-467a-b276-b29fe38bc95f
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
