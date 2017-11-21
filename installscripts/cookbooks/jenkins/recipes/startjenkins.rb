#
# Cookbook Name:: jenkins
# Recipe:: default
#
# Copyright 2017, YOUR_COMPANY_NAME
#

execute 'resizeJenkinsMemorySettings' do
  command "sudo sed -i 's/JENKINS_JAVA_OPTIONS=.*.$/JENKINS_JAVA_OPTIONS=\"-Djava.awt.headless=true -Xmx1024m -XX:MaxPermSize=512m\"/' /etc/sysconfig/jenkins"
end
execute 'chmodservices' do
  command "chmod -R 755 /home/ec2-user/cookbooks/jenkins/files;"
end
directory '/var/lib/jenkins/workspace' do
  owner 'jenkins'
  group 'jenkins'
  mode '0777'
  recursive true
  action :create
end
service "jenkins" do
  supports [:stop, :start, :restart]
  action [:start]
end
execute 'copyJenkinsClientJar' do
  command "cp #{node['client']['jar']} /home/ec2-user/jenkins-cli.jar; chmod 755 /home/ec2-user/jenkins-cli.jar"
end
execute 'createadmin' do
  command "sleep 30;echo 'jenkins.model.Jenkins.instance.securityRealm.createAccount(\"jenkinsadmin\", \"jenkinsadmin\")' | java -jar #{node['client']['jar']} -auth admin:`cat /var/lib/jenkins/secrets/initialAdminPassword` -s http://localhost:8080/ groovy ="
end
execute 'createJobExecUser' do
  command "sleep 30;echo 'jenkins.model.Jenkins.instance.securityRealm.createAccount(\"jobexec\", \"jenkinsadmin\")' | java -jar #{node['client']['jar']} -auth @#{node['authfile']} -s http://localhost:8080/ groovy ="
end

execute 'copyXmls' do
  command "tar -xvf /home/ec2-user/cookbooks/jenkins/files/default/xmls.tar"
  cwd "/var/lib/jenkins"
end
execute 'copyConfigXml' do
  command "cp /home/ec2-user/cookbooks/jenkins/files/node/config.xml ."
  cwd "/var/lib/jenkins"
end
execute 'copyCredentialsXml' do
  command "cp /home/ec2-user/cookbooks/jenkins/files/credentials/credentials.xml ."
  cwd "/var/lib/jenkins"
end
# script approvals going in with  xmls.tar will be overwritten
execute 'copyScriptApprovals' do
  command "cp #{node['jenkins']['scriptApprovalfile']} #{node['jenkins']['scriptApprovalfiletarget']}"
end
service "jenkins" do
  supports [:stop, :start, :restart]
  action [:restart]
end

#execute 'downloadJenkinsClient' do
#  command "sleep 20;curl -L #{node['client']['url']} -o #{node['client']['jar']}"
#end

execute 'downloadgitproj' do
  command "/usr/local/git/bin/git clone -b #{node['git_branch']} https://github.com/tmobile/jazz.git jazz-core"

  cwd '/home/ec2-user'
end
# downloading and running mvn assembly will be don on installer box. This will be uploaded to jenkins master using scp
#execute 'runAwsgatewayImporter' do
#  command "/opt/apache-maven-3.5.0/bin/mvn assembly:assembly -Dmaven.test.skip=true "
#  cwd '/home/ec2-user/jazz-core/aws-apigateway-importer'
#end
execute 'copylinkdir' do
  command "cp -rf /home/ec2-user/jazz-core/aws-apigateway-importer /tmp; chmod -R 777 /tmp/aws-apigateway-importer"
end

#credentials file go with xmls.tar
#execute 'deletecredentials-jenkins1' do
#  command "java -jar ./jenkins-cli.jar -auth jenkinsadmin:jenkinsadmin -s http://localhost:8080/ delete-credentials system::system::jenkins \"(global)\" 642cdc8d-a9f4-4f80-b73c-863ccd522765 "
#end
#execute 'deletecredentials-aws' do
#  command "java -jar ./jenkins-cli.jar -auth jenkinsadmin:jenkinsadmin -s http://localhost:8080/ delete-credentials system::system::jenkins \"(global)\" 2c88b8e9-52f7-467a-b276-b29fe38bc95f "
#end

execute 'createcredentials-jenkins1' do
  command "sleep 30;/home/ec2-user/cookbooks/jenkins/files/credentials/jenkins1.sh localhost "
end
execute 'createcredentials-jobexecutor' do
  command "/home/ec2-user/cookbooks/jenkins/files/credentials/jobexec.sh localhost "
end
execute 'createcredentials-aws' do
  command "/home/ec2-user/cookbooks/jenkins/files/credentials/aws.sh localhost "
end
#execute 'createcredentials-ec2-user' do
#  command "/home/ec2-user/cookbooks/jenkins/files/credentials/ec2-user.sh localhost "
#end



execute 'createJob-create-service' do
  command "/home/ec2-user/cookbooks/jenkins/files/jobs/job_create-service.sh localhost create-service #{node['bitbucketelb']}"
end
execute 'createJob-delete-service' do
  command "/home/ec2-user/cookbooks/jenkins/files/jobs/job_delete-service.sh localhost delete-service #{node['bitbucketelb']}"
end
execute 'createJob-job_pack_java_api' do
  command "/home/ec2-user/cookbooks/jenkins/files/jobs/job_build_java_api.sh localhost build_pack_api #{node['bitbucketelb']}"
end
execute 'createJob-bitbucketteam_newService' do
  command "/home/ec2-user/cookbooks/jenkins/files/jobs/job_bitbucketteam_newService.sh localhost bitbucketteam_newService #{node['bitbucketelb']}"
end
execute 'job_build-deploy-platform-service' do
  command "/home/ec2-user/cookbooks/jenkins/files/jobs/job_build-deploy-platform-service.sh localhost build-deploy-platform-service  #{node['bitbucketelb']}  #{node['region']}"
end
execute 'job_deploy-all-platform-services' do
  command "/home/ec2-user/cookbooks/jenkins/files/jobs/job_deploy-all-platform-services.sh localhost deploy-all-platform-services #{node['bitbucketelb']}  #{node['region']}"
end
execute 'createJob-job-pack-lambda' do
  command "/home/ec2-user/cookbooks/jenkins/files/jobs/job_build_pack_lambda.sh localhost build-pack-lambda #{node['bitbucketelb']}"
end

execute 'createJob-job-build-pack-website' do
  command "/home/ec2-user/cookbooks/jenkins/files/jobs/job_build_pack_website.sh localhost build-pack-website #{node['bitbucketelb']}"
end

link '/usr/bin/aws-api-import' do
  to '/home/ec2-user/jazz-core/aws-apigateway-importer/aws-api-import.sh'
  owner 'jenkins'
  group 'jenkins'
  mode '0777'
end
link '/usr/bin/aws' do
  to '/usr/local/bin/aws'
  owner 'root'
  group 'root'
  mode '0777'
end

execute 'configureJenkinsProperites' do
  command "/home/ec2-user/cookbooks/jenkins/files/node/configureJenkinsProps.sh localhost "
end

execute 'configJenkinsLocConfigXml' do
  command "/home/ec2-user/cookbooks/jenkins/files/node/configJenkinsLocConfigXml.sh  #{node['jenkinselb']} #{node['jenkins']['SES-defaultSuffix']}"
end

execute 'configJenkinsEmailExtXml' do
  command "/home/ec2-user/cookbooks/jenkins/files/node/configJenkinsEmailExtXml.sh #{node['jenkins']['SES-defaultSuffix']} #{node['jenkins']['SES-smtpAuthUsername']} #{node['jenkins']['SES-smtpAuthPassword']} #{node['jenkins']['SES-smtpHost']} #{node['jenkins']['SES-useSsl']} #{node['jenkins']['SES-smtpPort']} #{node['jenkinselb']}"
end

execute 'configJenkinsTaskMailerXml' do
  command "/home/ec2-user/cookbooks/jenkins/files/node/configJenkinsTaskMailerXml.sh #{node['jenkins']['SES-smtpAuthUsername']} #{node['jenkins']['SES-smtpAuthPassword']} #{node['jenkins']['SES-smtpHost']} #{node['jenkins']['SES-useSsl']} #{node['jenkinselb']}"
end

# config.xml is added in xmls.tar
#execute 'copyJenkinsConfigfile' do
#  command "cp #{node['jenkins']['configfile']} #{node['jenkins']['configfiletarget']}"
#end

execute 'copyJenkinsPropertyfile' do
  command "cp #{node['jenkins']['propertyfile']} #{node['jenkins']['propertyfiletarget']};chmod 777  #{node['jenkins']['propertyfiletarget']}"
  cwd '/home/ec2-user'
end
execute 'chownJenkinsfolder' do
  command "chown jenkins:jenkins /var/lib/jenkins"
end

service "jenkins" do
  supports [:stop, :start, :restart]
  action [:restart]
end
execute 'copyJobBuildPackApi' do
  command "sleep 20;/home/ec2-user/cookbooks/jenkins/files/jobs/copyJob.sh localhost build_pack_api build_pack_api_dev"
end
execute 'copyJobBuildPackLambda' do
  command "sleep 20;/home/ec2-user/cookbooks/jenkins/files/jobs/copyJob.sh localhost build-pack-lambda build-pack-lambda-dev"
end
execute 'copyJobBuildPackLambda' do
  command "sleep 20;/home/ec2-user/cookbooks/jenkins/files/jobs/copyJob.sh localhost build-pack-website build-pack-website-dev"
end
