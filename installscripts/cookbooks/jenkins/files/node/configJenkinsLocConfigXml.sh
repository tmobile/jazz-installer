JENKINSELB=$1
JENKINS_LOC_CONFIG_XML=/var/lib/jenkins/jenkins.model.JenkinsLocationConfiguration.xml
sed  -i "s=jenkinsUrl.*.$=jenkinsUrl>http://$JENKINSELB:8080/</jenkinsUrl>=g" $JENKINS_LOC_CONFIG_XML

