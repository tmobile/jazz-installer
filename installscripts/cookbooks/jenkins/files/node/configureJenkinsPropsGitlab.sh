JENKINS_URL=http://$1/ # localhost or jenkins elb url
SSH_USER=$2

if [ -f /etc/redhat-release ]; then
  JENKINS_PROPFILE=/home/$SSH_USER/cookbooks/jenkins/files/node/jenkins-conf.properties
  AUTHFILE=/home/$SSH_USER/cookbooks/jenkins/files/default/authfile
  JENKINS_CLI=/home/$SSH_USER/jenkins-cli.jar
elif [ -f /etc/lsb-release ]; then
  JENKINS_PROPFILE=/root/cookbooks/jenkins/files/node/jenkins-conf.properties
  AUTHFILE=/root/cookbooks/jenkins/files/default/authfile
  JENKINS_CLI=/root/jenkins-cli.jar
fi

echo "$0 $1 $2 "
REPO_CREDENTIAL_ID=`java -jar $JENKINS_CLI -s $JENKINS_URL -auth @$AUTHFILE list-credentials system::system::jenkins | grep "Jazz-Gitlab-Cred"|cut -d" " -f1`
AWS_CREDENTIAL_ID=`java -jar $JENKINS_CLI -s $JENKINS_URL -auth @$AUTHFILE list-credentials system::system::jenkins | grep "AWS Credentials"|cut -d" " -f1`
JENKINS_CREDENTIAL_ID=`java -jar $JENKINS_CLI -s $JENKINS_URL -auth @$AUTHFILE list-credentials system::system::jenkins | grep "jobexec"|cut -d" " -f1`
sed -i "s/REPO_CREDENTIAL_ID=.*.$/REPO_CREDENTIAL_ID=$REPO_CREDENTIAL_ID/g" $JENKINS_PROPFILE
sed -i "s/AWS_CREDENTIAL_ID=.*.$/AWS_CREDENTIAL_ID=$AWS_CREDENTIAL_ID/g" $JENKINS_PROPFILE
sed -i "s/JENKINS_CREDENTIAL_ID=.*.$/JENKINS_CREDENTIAL_ID=$JENKINS_CREDENTIAL_ID/g" $JENKINS_PROPFILE
