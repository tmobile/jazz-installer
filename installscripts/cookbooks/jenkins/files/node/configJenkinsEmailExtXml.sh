#This script will add/change the hudson.plugins.emailext.ExtendedEmailPublisher.xml
#configuration in /var/lib/jenkins/

SMTP_DEFAULT_SUFFIX=$1
SMTP_AUTH_USERNAME=$2
SMTP_AUTH_PASSWORD=$3
SMTP_HOST=$4
SMTP_USE_SSL=$5
SMTP_PORT=$6
JENKINS_URL=http://$7:8080/


#Jenkins ExtendedEmailPublisher XML
JENKINS_EMAIL_EXT_CONFIG_XML=/var/lib/jenkins/hudson.plugins.emailext.ExtendedEmailPublisher.xml
JENKINS_CLI=/home/ec2-user/jenkins-cli.jar
ENCRYPT_PASSWORD_SCRIPT=/home/ec2-user/encrypt.groovy

#Populating all the variables necessary
sed  -i "s=useSsl.*.$=useSsl>$SMTP_USE_SSL</useSsl>=g" $JENKINS_EMAIL_EXT_CONFIG_XML

SMTP_PORT_LINE=" <smtpPort>$SMTP_PORT</smtpPort>"
sed -i "3 i \ ${SMTP_PORT_LINE}" $JENKINS_EMAIL_EXT_CONFIG_XML

SMTP_HOST_LINE=" <smtpHost>$SMTP_HOST</smtpHost>"
sed -i "3 i \ ${SMTP_HOST_LINE}" $JENKINS_EMAIL_EXT_CONFIG_XML

#Get the Encrypted password using the Groovy script
SMTP_AUTH_PASSWORD_ENCRYPT="$(java -jar $JENKINS_CLI -remoting -s $JENKINS_URL groovy $ENCRYPT_PASSWORD_SCRIPT $SMTP_AUTH_PASSWORD --username jenkinsadmin --password jenkinsadmin)"
SMTP_AUTH_PASSWORD_ENCRYPT_LINE=" <smtpAuthPassword>$SMTP_AUTH_PASSWORD_ENCRYPT</smtpAuthPassword>"
sed -i "3 i \ ${SMTP_AUTH_PASSWORD_ENCRYPT_LINE}" $JENKINS_EMAIL_EXT_CONFIG_XML

SMTP_AUTH_USERNAME_LINE=" <smtpAuthUsername>$SMTP_AUTH_USERNAME</smtpAuthUsername>"
sed -i "3 i \ ${SMTP_AUTH_USERNAME_LINE}" $JENKINS_EMAIL_EXT_CONFIG_XML

SMTP_DEFAULT_SUFFIX_LINE=" <defaultSuffix>$SMTP_DEFAULT_SUFFIX</defaultSuffix>"
sed -i "3 i \ ${SMTP_DEFAULT_SUFFIX_LINE}" $JENKINS_EMAIL_EXT_CONFIG_XML
 

