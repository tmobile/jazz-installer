JENKINS_URL=http://$1/ # localhost or jenkins elb url
SSH_USER=$2

AUTHFILE=/home/$SSH_USER/cookbooks/jenkins/files/default/authfile
JENKINS_CLI=/home/$SSH_USER/jenkins-cli.jar

echo "$0 $1 $2 "
cat <<EOF | java -jar $JENKINS_CLI -s $JENKINS_URL -auth @$AUTHFILE create-credentials-by-xml system::system::jenkins "(global)"
<com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>
  <scope>GLOBAL</scope>
  <id>SVC_ADMIN</id>
  <description>Jazz Admin User</description>
  <username>cognitouser</username>
  <password>cognitopasswd</password>
</com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>
EOF
