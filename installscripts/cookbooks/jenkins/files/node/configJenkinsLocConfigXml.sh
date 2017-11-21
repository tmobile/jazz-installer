#This script will add/change the jenkins.model.JenkinsLocationConfiguration.xml
#configuration in /var/lib/jenkins/

JENKINSELB=$1
ADMIN_ADDRESS=$2

JENKINS_LOC_CONFIG_XML=/var/lib/jenkins/jenkins.model.JenkinsLocationConfiguration.xml

sed  -i "s=adminAddress.*.$=adminAddress>$ADMIN_ADDRESS</adminAddress>=g" $JENKINS_LOC_CONFIG_XML
sed  -i "s=jenkinsUrl.*.$=jenkinsUrl>http://$JENKINSELB:8080/</jenkinsUrl>=g" $JENKINS_LOC_CONFIG_XML


