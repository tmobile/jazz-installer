#This script will add/change the hudson.tasks.Mailer.xml
#configuration in /var/lib/jenkins/

SMTP_AUTH_USERNAME=$1
SMTP_AUTH_PASSWORD=$2
SMTP_HOST=$3
SMTP_USE_SSL=$4
JENKINS_URL=http://$5/
JENKINSUSER=$6
JENKINSPASSWD=$7
SSH_USER=$8

#Jenkins TaskMailerPublisher XML
JENKINS_TASK_MAILER_CONFIG_XML=/var/lib/jenkins/hudson.tasks.Mailer.xml
if [ -f /etc/redhat-release ]; then
  JENKINS_CLI=/home/$SSH_USER/jenkins-cli.jar
  ENCRYPT_PASSWORD_SCRIPT=/home/$SSH_USER/encrypt.groovy
elif [ -f /etc/lsb-release ]; then
  JENKINS_CLI=/root/jenkins-cli.jar
  ENCRYPT_PASSWORD_SCRIPT=/root/encrypt.groovy
fi
SMTP_PORT=465

#Populating all the variables necessary
SMTP_PORT_LINE=" <smtpPort>$SMTP_PORT</smtpPort>"
sed -i "3 i \ ${SMTP_PORT_LINE}" $JENKINS_TASK_MAILER_CONFIG_XML

sed  -i "s=useSsl.*.$=useSsl>$SMTP_USE_SSL</useSsl>=g" $JENKINS_TASK_MAILER_CONFIG_XML

SMTP_HOST_LINE=" <smtpHost>$SMTP_HOST</smtpHost>"
sed -i "3 i \ ${SMTP_HOST_LINE}" $JENKINS_TASK_MAILER_CONFIG_XML

#Get the Encrypted password using the Groovy script
SMTP_AUTH_PASSWORD_ENCRYPT="$(java -jar $JENKINS_CLI -remoting -s $JENKINS_URL groovy $ENCRYPT_PASSWORD_SCRIPT $SMTP_AUTH_PASSWORD --username $JENKINSUSER --password $JENKINSPASSWD)"
SMTP_AUTH_PASSWORD_ENCRYPT_LINE=" <smtpAuthPassword>$SMTP_AUTH_PASSWORD_ENCRYPT</smtpAuthPassword>"
sed -i "3 i \ ${SMTP_AUTH_PASSWORD_ENCRYPT_LINE}" $JENKINS_TASK_MAILER_CONFIG_XML

SMTP_AUTH_USERNAME_LINE=" <smtpAuthUsername>$SMTP_AUTH_USERNAME</smtpAuthUsername>"
sed -i "3 i \ ${SMTP_AUTH_USERNAME_LINE}" $JENKINS_TASK_MAILER_CONFIG_XML
