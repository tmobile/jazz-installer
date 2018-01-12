JENKINS_URL=http://$1/ # localhost or jenkins elb url
SSH_USER=$2

if [ -f /etc/redhat-release ]; then
  AUTHFILE=/home/$SSH_USER/cookbooks/jenkins/files/default/authfile
  JENKINS_CLI=/home/$SSH_USER/jenkins-cli.jar
elif [ -f /etc/lsb-release ]; then
  AUTHFILE=/root/cookbooks/jenkins/files/default/authfile
  JENKINS_CLI=/root/jenkins-cli.jar
fi

AWS_ACCESS_KEY="Replaced with sed command from create.sh"
AWS_SECRET_KEY="Replaced with sed command from create.sh"
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
