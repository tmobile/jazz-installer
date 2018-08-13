#!/bin/bash

jenkinsurl=$1
email=$2
jenkinshome=$3
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
curl -sL http://$jenkinsurl/jnlpJars/jenkins-cli.jar -o jenkins-cli.jar

if [ "$scm_type" == "bitbucket" ]; then
  scmpath=$scmpath/scm
fi

java -jar jenkins-cli.jar -auth $jenkinsuser:$jpassword -s  http://$jenkinsurl groovy = <<EOF
import jenkins.model.JenkinsLocationConfiguration
c = JenkinsLocationConfiguration.get()
c.url = 'https://$jenkinsurl'
c.adminAddress = '$email'
c.save()
jenkins.model.Jenkins.instance.securityRealm.createAccount("jobexec", "jenkinsadmin")
EOF

if [ "$scm_type" == "gitlab" ]; then
  java -jar jenkins-cli.jar -auth $jenkinsuser:$jpassword -s  http://$jenkinsurl groovy = <<EOF
  def cmd = ['/bin/sh',  '-c',  'sed -i "s/ip/$scm_elb/g" $jenkinshome/com.dabsquared.gitlabjenkins.connection.GitLabConnectionConfig.xml']
  cmd.execute()
EOF
  ../jenkinscli/credentials/gitlab-user.sh "java -jar jenkins-cli.jar -auth $jenkinsuser:$jpassword -s  http://$jenkinsurl" $gitlabuser $gitlabpassword
  ../jenkinscli/credentials/gitlab-token.sh "java -jar jenkins-cli.jar -auth $jenkinsuser:$jpassword -s  http://$jenkinsurl" $gitlabtoken
else
  ../jenkinscli/credentials/bitbucket-creds.sh "java -jar jenkins-cli.jar -auth $jenkinsuser:$jpassword -s  http://$jenkinsurl" $bbuser $bbpassword
fi

#credentials
../jenkinscli/credentials/jobexec.sh "java -jar jenkins-cli.jar -auth $jenkinsuser:$jpassword -s  http://$jenkinsurl"
../jenkinscli/credentials/sonar.sh "java -jar jenkins-cli.jar -auth $jenkinsuser:$jpassword -s  http://$jenkinsurl" $sonaruser $sonarpassword
../jenkinscli/credentials/aws.sh "java -jar jenkins-cli.jar -auth $jenkinsuser:$jpassword -s  http://$jenkinsurl" $aws_access_key $aws_secret_key
../jenkinscli/credentials/cognitouser.sh "java -jar jenkins-cli.jar -auth $jenkinsuser:$jpassword -s  http://$jenkinsurl" $cognitouser $cognitopassword

#Jobs
../jenkinscli/jobs/job_create-service.sh "java -jar jenkins-cli.jar -auth $jenkinsuser:$jpassword -s  http://$jenkinsurl" $scmpath
../jenkinscli/jobs/job_delete-service.sh "java -jar jenkins-cli.jar -auth $jenkinsuser:$jpassword -s  http://$jenkinsurl" $scmpath
../jenkinscli/jobs/job_build_pack_api.sh "java -jar jenkins-cli.jar -auth $jenkinsuser:$jpassword -s  http://$jenkinsurl" $scmpath
../jenkinscli/jobs/job_cleanup_cloudfront_distributions.sh "java -jar jenkins-cli.jar -auth $jenkinsuser:$jpassword -s  http://$jenkinsurl" $scmpath
../jenkinscli/jobs/job_build_pack_lambda.sh "java -jar jenkins-cli.jar -auth $jenkinsuser:$jpassword -s  http://$jenkinsurl" $scmpath
../jenkinscli/jobs/job_build_pack_website.sh "java -jar jenkins-cli.jar -auth $jenkinsuser:$jpassword -s  http://$jenkinsurl" $scmpath
../jenkinscli/jobs/job_jazz_ui.sh "java -jar jenkins-cli.jar -auth $jenkinsuser:$jpassword -s  http://$jenkinsurl" $scmpath
