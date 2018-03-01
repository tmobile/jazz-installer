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
        <com.dabsquared.gitlabjenkins.connection.GitLabApiTokenImpl plugin="gitlab-plugin@1.5.2">
          <scope>GLOBAL</scope>
          <id>Jazz-Gitlab-API-Cred</id>
          <description>Jazz-Gitlab-API-Cred</description>
          <apiToken>replace</apiToken>
        </com.dabsquared.gitlabjenkins.connection.GitLabApiTokenImpl>
EOF
