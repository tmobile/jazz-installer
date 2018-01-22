JENKINS_URL=http://$1/ # localhost or jenkins elb url
SSH_USER=$2

if [ -f /etc/redhat-release ]; then
  AUTHFILE=/home/$SSH_USER/cookbooks/jenkins/files/default/authfile
  JENKINS_CLI=/home/$SSH_USER/jenkins-cli.jar
elif [ -f /etc/lsb-release ]; then
  AUTHFILE=/root/cookbooks/jenkins/files/default/authfile
  JENKINS_CLI=/root/jenkins-cli.jar
fi
echo "$0 $1 $2 "
cat <<EOF | java -jar $JENKINS_CLI -s $JENKINS_URL -auth @$AUTHFILE create-credentials-by-xml system::system::jenkins "(global)"
<com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>
  <scope>GLOBAL</scope>
  <id>jenkins1cred</id>
  <description>Gitlab user</description>
  <username>gitlabuser</username>
  <password>gitlabpassword</password>
</com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>
EOF
