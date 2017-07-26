JENKINS_URL=http://$1:8080/ # localhost or jenkins elb url
JENKINS_PROPFILE=/home/ec2-user/cookbooks/jenkins/files/node/jenkins-conf.properties
AUTHFILE=/home/ec2-user/cookbooks/jenkins/files/default/authfile
JENKINS_CLI=/home/ec2-user/jenkins-cli.jar
echo "$0 $1 $2 "
REPO_CREDENTIAL_ID=`java -jar $JENKINS_CLI -s $JENKINS_URL -auth @$AUTHFILE list-credentials system::system::jenkins | grep "jenkins1"|cut -d" " -f1`
AWS_CREDENTIAL_ID=`java -jar $JENKINS_CLI -s $JENKINS_URL -auth @$AUTHFILE list-credentials system::system::jenkins | grep "AWS Credentials"|cut -d" " -f1`
JENKINS_CREDENTIAL_ID=`java -jar $JENKINS_CLI -s $JENKINS_URL -auth @$AUTHFILE list-credentials system::system::jenkins | grep "jobexec"|cut -d" " -f1`
sed -i "s/REPO_CREDENTIAL_ID=.*.$/REPO_CREDENTIAL_ID=$REPO_CREDENTIAL_ID/g" $JENKINS_PROPFILE
sed -i "s/AWS_CREDENTIAL_ID=.*.$/AWS_CREDENTIAL_ID=$AWS_CREDENTIAL_ID/g" $JENKINS_PROPFILE
sed -i "s/JENKINS_CREDENTIAL_ID=.*.$/JENKINS_CREDENTIAL_ID=$JENKINS_CREDENTIAL_ID/g" $JENKINS_PROPFILE
