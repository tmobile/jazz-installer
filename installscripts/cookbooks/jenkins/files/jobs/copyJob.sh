JENKINS_URL=http://$1:8080/ # localhost or jenkins elb url
SRC_JOB_NAME=$2
DEST_JOB_NAME=$3
SSH_USER=$4

if [ -f /etc/redhat-release ]; then
  AUTHFILE=/home/$SSH_USER/cookbooks/jenkins/files/default/authfile
  JENKINS_CLI=/home/$SSH_USER/jenkins-cli.jar
elif [ -f /etc/lsb-release ]; then
  AUTHFILE=/root/cookbooks/jenkins/files/default/authfile
  JENKINS_CLI=/root/jenkins-cli.jar
fi

echo "$0 $1 $2 $3"
java -jar $JENKINS_CLI -s $JENKINS_URL -auth @$AUTHFILE copy-job $SRC_JOB_NAME $DEST_JOB_NAME
