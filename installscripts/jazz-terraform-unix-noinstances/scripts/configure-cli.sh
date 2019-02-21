#!/bin/bash

jenkinsurl=$1
email=$2
if [ "$3" == "1" ]; then
  jenkinshome='/var/jenkins_home'
else
  jenkinshome='/var/lib/jenkins'
fi
scm_elb=$4
gitlabuser=$5
gitlabpassword=$6
gitlabtoken=$7
jpassword=$8
scm_type=$9
bbuser=$5
bbpassword=$6
sonaruser=${10}
sonarpassword=${11}
aws_access_key=${12}
aws_secret_key=${13}
cognitouser=${2}
cognitopassword=${14}
scmpath=$4
jenkinsuser=${15}
acluser=${16}
aclpassword=${17}
curl -sL http://"$jenkinsurl"/jnlpJars/jenkins-cli.jar -o jenkins-cli.jar

if [ "$scm_type" == "bitbucket" ]; then
  scmpath=$scmpath/scm
fi
jenkins_cli_command="java -jar jenkins-cli.jar -auth $jenkinsuser:$jpassword -s  http://$jenkinsurl"
$jenkins_cli_command groovy = <<EOF
import jenkins.model.JenkinsLocationConfiguration
c = JenkinsLocationConfiguration.get()
c.url = 'http://$jenkinsurl'
c.adminAddress = '$email'
c.save()
jenkins.model.Jenkins.instance.securityRealm.createAccount("jobexec", "$jpassword")
EOF

if [ "$scm_type" == "gitlab" ]; then
  $jenkins_cli_command groovy = <<EOF
  def cmd = ['/bin/sh',  '-c',  'sed -i "s/ip/$scm_elb/g" $jenkinshome/com.dabsquared.gitlabjenkins.connection.GitLabConnectionConfig.xml']
  cmd.execute()
EOF
  ../jenkinscli/credentials/gitlab-user.sh "$jenkins_cli_command" "$gitlabuser" "$gitlabpassword"
  ../jenkinscli/credentials/gitlab-token.sh "$jenkins_cli_command" "$gitlabtoken"
else
  ../jenkinscli/credentials/bitbucket-creds.sh "$jenkins_cli_command" "$bbuser" "$bbpassword"
fi

#credentials
../jenkinscli/credentials/jobexec.sh "$jenkins_cli_command"
../jenkinscli/credentials/sonar.sh "$jenkins_cli_command" "$sonaruser" "$sonarpassword"
../jenkinscli/credentials/aws.sh "$jenkins_cli_command" "$aws_access_key" "$aws_secret_key"
../jenkinscli/credentials/cognitouser.sh "$jenkins_cli_command" "$cognitouser" "$cognitopassword"
../jenkinscli/credentials/acl.sh "$jenkins_cli_command" "$acluser" "$aclpassword"
#Jobs
../jenkinscli/jobs/job_create-service.sh "$jenkins_cli_command" "$scmpath"
../jenkinscli/jobs/job_delete-service.sh "$jenkins_cli_command" "$scmpath"
../jenkinscli/jobs/job_build_pack_api.sh "$jenkins_cli_command" "$scmpath"
../jenkinscli/jobs/job_cleanup_cloudfront_distributions.sh "$jenkins_cli_command" "$scmpath"
../jenkinscli/jobs/job_build_pack_lambda.sh "$jenkins_cli_command" "$scmpath"
../jenkinscli/jobs/job_build_pack_website.sh "$jenkins_cli_command" "$scmpath"
../jenkinscli/jobs/job_jazz_ui.sh "$jenkins_cli_command" "$scmpath"

#restart
$jenkins_cli_command restart
sleep 45 &
