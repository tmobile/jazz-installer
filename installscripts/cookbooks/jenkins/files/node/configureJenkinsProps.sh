JENKINS_URL=http://$1/ # localhost or jenkins elb url
SSH_USER=$2

JENKINS_PROPFILE=/home/$SSH_USER/cookbooks/jenkins/files/node/jenkins-conf.properties
JENKINS_JSON_PROPFILE=/home/$SSH_USER/cookbooks/jenkins/files/node/jazz-installer-vars.json
AUTHFILE=/home/$SSH_USER/cookbooks/jenkins/files/default/authfile
JENKINS_CLI=/home/$SSH_USER/jenkins-cli.jar

echo "$0 $1 $2 "
REPO_CREDENTIAL_ID=`java -jar $JENKINS_CLI -s $JENKINS_URL -auth @$AUTHFILE list-credentials system::system::jenkins | grep "jenkins1"|cut -d" " -f1`
AWS_CREDENTIAL_ID=`java -jar $JENKINS_CLI -s $JENKINS_URL -auth @$AUTHFILE list-credentials system::system::jenkins | grep "AWS Credentials"|cut -d" " -f1`
JENKINS_CREDENTIAL_ID=`java -jar $JENKINS_CLI -s $JENKINS_URL -auth @$AUTHFILE list-credentials system::system::jenkins | grep "jobexec"|cut -d" " -f1`

sed -i "s/REPO_CREDENTIAL_ID=.*.$/REPO_CREDENTIAL_ID=$REPO_CREDENTIAL_ID/g" $JENKINS_PROPFILE
sed -i "s/AWS_CREDENTIAL_ID=.*.$/AWS_CREDENTIAL_ID=$AWS_CREDENTIAL_ID/g" $JENKINS_PROPFILE
sed -i "s/JENKINS_CREDENTIAL_ID=.*.$/JENKINS_CREDENTIAL_ID=$JENKINS_CREDENTIAL_ID/g" $JENKINS_PROPFILE


#JSON Format
sed -i "s/REPO_CREDENTIAL_ID\".*.$/REPO_CREDENTIAL_ID\": \"$REPO_CREDENTIAL_ID\",/g" $JENKINS_JSON_PROPFILE
sed -i "s/AWS_CREDENTIAL_ID\".*.$/AWS_CREDENTIAL_ID\": \"$AWS_CREDENTIAL_ID/\",g" $JENKINS_JSON_PROPFILE
sed -i "s/JENKINS_CREDENTIAL_ID\".*.$/JENKINS_CREDENTIAL_ID\": \"$JENKINS_CREDENTIAL_ID\"/g" $JENKINS_JSON_PROPFILE
