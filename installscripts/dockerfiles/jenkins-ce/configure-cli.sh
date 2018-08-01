#!/bin/bash
read_default_var()
{
exec < $1
while read line
do
        match=`echo $line|grep $2 `
        if [ $? -eq 0 ]; then
        echo `echo $line|cut -d '=' -f 2` | sed -e 's/^"//' -e 's/"$//' | sed -e "s/^'//" -e "s/'$//"
        fi
done
}

jenkinsurl=$(read_default_var ../cookbooks/jenkins/attributes/default.rb "default\['jenkinselb'\]")
gitlabuser=$(read_default_var ../cookbooks/jenkins/attributes/default.rb "default\['gitlabuser'\]")
gitlabpassword=$(read_default_var ../cookbooks/jenkins/attributes/default.rb "default\['gitlabpassword'\]")
gitlabtoken=$(read_default_var ../cookbooks/jenkins/attributes/default.rb "default\['gitlabtoken'\]")
jpassword=$(read_default_var ../jazz-terraform-unix-noinstances/terraform.tfvars "jenkinspasswd")
scm_type=$(read_default_var ../cookbooks/jenkins/attributes/default.rb "default\['scm'\]")
bbuser=$(read_default_var ../cookbooks/jenkins/attributes/default.rb "default\['bbuser'\]")
bbpassword=$(read_default_var ../cookbooks/jenkins/attributes/default.rb "default\['bbpassword'\]")
sonaruser=$(read_default_var ../cookbooks/jenkins/attributes/default.rb "default\['sonaruser'\]")
sonarpassword=$(read_default_var ../cookbooks/jenkins/attributes/default.rb "default\['sonarpassword'\]")
aws_access_key=$(read_default_var ../cookbooks/jenkins/attributes/default.rb "default\['aws_access_key'\]")
aws_secret_key=$(read_default_var ../cookbooks/jenkins/attributes/default.rb "default\['aws_secret_key'\]")
cognitouser=$(read_default_var ../cookbooks/jenkins/attributes/default.rb "default\['cognitouser'\]")
cognitopassword=$(read_default_var ../cookbooks/jenkins/attributes/default.rb "default\['cognitopassword'\]")
scmpath=$(read_default_var ../cookbooks/jenkins/attributes/default.rb "default\['scmpath'\]")

curl -sL http://$jenkinsurl/jnlpJars/jenkins-cli.jar -o jenkins-cli.jar
java -jar jenkins-cli.jar -auth admin:$jpassword -s  http://$jenkinsurl groovy = <<'EOF'
jenkins.model.Jenkins.instance.securityRealm.createAccount("jobexec", "jenkinsadmin")
def cmd = ['/bin/sh',  '-c',  'sed  -i "s=adminAddress.*.$=adminAddress>ADMINREPLACEADDRESS</adminAddress>=g" HOMEJENKINS/jenkins.model.JenkinsLocationConfiguration.xml && \
sed  -i "s=jenkinsUrl.*.$=jenkinsUrl>http://REPLACEJENKINSURL/</jenkinsUrl>=g" HOMEJENKINS/jenkins.model.JenkinsLocationConfiguration.xml && \
sed -i "s/ip/SCMELB/g" HOMEJENKINS/com.dabsquared.gitlabjenkins.connection.GitLabConnectionConfig.xml']
cmd.execute().with{
    def output = new StringWriter()
    def error = new StringWriter()
    //wait for process ended and catch stderr and stdout.
    it.waitForProcessOutput(output, error)
    //check there is no error
    println "error=$error"
    println "output=$output"
    println "code=${it.exitValue()}"
}
EOF

#If it is GitLab
../cookbooks/jenkins/files/credentials/gitlab-user.sh "java -jar jenkins-cli.jar -auth admin:$jpassword -s  http://$jenkinsurl" $gitlabuser $gitlabpassword
../cookbooks/jenkins/files/credentials/gitlab-token.sh "java -jar jenkins-cli.jar -auth admin:$jpassword -s  http://$jenkinsurl" $gitlabtoken
#If it is Bitbucket
../cookbooks/jenkins/files/credentials/bitbucket-creds.sh "java -jar jenkins-cli.jar -auth admin:$jpassword -s  http://$jenkinsurl" $bbuser $bbpassword

#credentials
../cookbooks/jenkins/files/credentials/jobexec.sh "java -jar jenkins-cli.jar -auth admin:$jpassword -s  http://$jenkinsurl"
../cookbooks/jenkins/files/credentials/sonar.sh "java -jar jenkins-cli.jar -auth admin:$jpassword -s  http://$jenkinsurl" $sonaruser $sonarpassword
../cookbooks/jenkins/files/credentials/aws.sh "java -jar jenkins-cli.jar -auth admin:$jpassword -s  http://$jenkinsurl" $aws_access_key $aws_secret_key
../cookbooks/jenkins/files/credentials/cognitouser.sh "java -jar jenkins-cli.jar -auth admin:$jpassword -s  http://$jenkinsurl" $cognitouser $cognitopassword

#Jobs
../cookbooks/jenkins/files/jobs/job_create-service.sh "java -jar jenkins-cli.jar -auth admin:$jpassword -s  http://$jenkinsurl" $scmpath
../cookbooks/jenkins/files/jobs/job_delete-service.sh "java -jar jenkins-cli.jar -auth admin:$jpassword -s  http://$jenkinsurl" $scmpath
../cookbooks/jenkins/files/jobs/job_build_pack_api.sh "java -jar jenkins-cli.jar -auth admin:$jpassword -s  http://$jenkinsurl" $scmpath
../cookbooks/jenkins/files/jobs/job_cleanup_cloudfront_distributions.sh "java -jar jenkins-cli.jar -auth admin:$jpassword -s  http://$jenkinsurl" $scmpath
../cookbooks/jenkins/files/jobs/job_build_pack_lambda.sh "java -jar jenkins-cli.jar -auth admin:$jpassword -s  http://$jenkinsurl" $scmpath
../cookbooks/jenkins/files/jobs/job_build_pack_website.sh "java -jar jenkins-cli.jar -auth admin:$jpassword -s  http://$jenkinsurl" $scmpath
../cookbooks/jenkins/files/jobs/job_jazz_ui.sh "java -jar jenkins-cli.jar -auth admin:$jpassword -s  http://$jenkinsurl" $scmpath
