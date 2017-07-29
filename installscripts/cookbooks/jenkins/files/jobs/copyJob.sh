JENKINS_URL=http://$1:8080/ # localhost or jenkins elb url
SRC_JOB_NAME=$2
DEST_JOB_NAME=$3
AUTHFILE=/home/ec2-user/cookbooks/jenkins/files/default/authfile
JENKINS_CLI=/home/ec2-user/jenkins-cli.jar
echo "$0 $1 $2 $3" 
java -jar $JENKINS_CLI -s $JENKINS_URL -auth @$AUTHFILE copy-job $SRC_JOB_NAME $DEST_JOB_NAME 
