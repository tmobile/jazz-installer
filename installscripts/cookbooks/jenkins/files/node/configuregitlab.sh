#Script to replace configs of gitlab
configxml=/var/lib/jenkins/com.dabsquared.gitlabjenkins.connection.GitLabConnectionConfig.xml

sed  -i "s/ip/$1/g" $configxml
