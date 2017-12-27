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
  command "chmod -R 755 /home/#{node['jenkins']['SSH_user']}/cookbooks/jenkins/files;"
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
  command "cp #{node['client']['jar']} /home/#{node['jenkins']['SSH_user']}/jenkins-cli.jar; chmod 755 /home/#{node['jenkins']['SSH_user']}/jenkins-cli.jar"
end
execute 'createadmin' do
  command "sleep 30;echo 'jenkins.model.Jenkins.instance.securityRealm.createAccount(\"jenkinsadmin\", \"jenkinsadmin\")' | java -jar #{node['client']['jar']} -auth admin:`cat /var/lib/jenkins/secrets/initialAdminPassword` -s http://$JENKINSELB/ groovy ="
end
execute 'createJobExecUser' do
  command "sleep 30;echo 'jenkins.model.Jenkins.instance.securityRealm.createAccount(\"jobexec\", \"jenkinsadmin\")' | java -jar #{node['client']['jar']} -auth @#{node['authfile']} -s http://$JENKINSELB/ groovy ="
end

execute 'copyXmls' do
  command "tar -xvf /home/#{node['jenkins']['SSH_user']}/cookbooks/jenkins/files/default/xmls.tar"
  cwd "/var/lib/jenkins"
end
execute 'copyConfigXml' do
  command "cp /home/#{node['jenkins']['SSH_user']}/cookbooks/jenkins/files/node/config.xml ."
  cwd "/var/lib/jenkins"
end
execute 'copyCredentialsXml' do
  command "cp /home/#{node['jenkins']['SSH_user']}/cookbooks/jenkins/files/credentials/credentials.xml ."
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

execute 'downloadgitproj' do
  command "/usr/local/git/bin/git clone -b #{node['git_branch']} https://github.com/tmobile/jazz.git jazz-core"

  cwd "/home/#{node['jenkins']['SSH_user']}"
end

execute 'copylinkdir' do
  command "cp -rf /home/#{node['jenkins']['SSH_user']}/jazz-core/aws-apigateway-importer /tmp; chmod -R 777 /tmp/aws-apigateway-importer"
end

execute 'createcredentials-jenkins1' do
  command "sleep 30;/home/#{node['jenkins']['SSH_user']}/cookbooks/jenkins/files/credentials/jenkins1.sh #{node['jenkinselb']} #{node['jenkins']['SSH_user']}"
end
execute 'createcredentials-jobexecutor' do
  command "/home/#{node['jenkins']['SSH_user']}/cookbooks/jenkins/files/credentials/jobexec.sh #{node['jenkinselb']} #{node['jenkins']['SSH_user']}"
end
execute 'createcredentials-aws' do
  command "/home/#{node['jenkins']['SSH_user']}/cookbooks/jenkins/files/credentials/aws.sh #{node['jenkinselb']} #{node['jenkins']['SSH_user']}"
end


execute 'createJob-create-service' do
  command "/home/#{node['jenkins']['SSH_user']}/cookbooks/jenkins/files/jobs/job_create-service.sh #{node['jenkinselb']} create-service #{node['bitbucketelb']} #{node['jenkins']['SSH_user']}"
end
execute 'createJob-delete-service' do
  command "/home/#{node['jenkins']['SSH_user']}/cookbooks/jenkins/files/jobs/job_delete-service.sh #{node['jenkinselb']} delete-service #{node['bitbucketelb']} #{node['jenkins']['SSH_user']}"
end
execute 'createJob-job_pack_java_api' do
  command "/home/#{node['jenkins']['SSH_user']}/cookbooks/jenkins/files/jobs/job_build_java_api.sh #{node['jenkinselb']} build_pack_api #{node['bitbucketelb']} #{node['jenkins']['SSH_user']}"
end
execute 'createJob-bitbucketteam_newService' do
  command "/home/#{node['jenkins']['SSH_user']}/cookbooks/jenkins/files/jobs/job_bitbucketteam_newService.sh #{node['jenkinselb']} bitbucketteam_newService #{node['bitbucketelb']} #{node['jenkins']['SSH_user']}"
end
execute 'createJob-platform_api_services' do
  command "/home/#{node['jenkins']['SSH_user']}/cookbooks/jenkins/files/jobs/job_platform_api_services.sh #{node['jenkinselb']} Platform API Services #{node['bitbucketelb']} #{node['jenkins']['SSH_user']}"
end
execute 'job_build-deploy-platform-service' do
  command "/home/#{node['jenkins']['SSH_user']}/cookbooks/jenkins/files/jobs/job_build-deploy-platform-service.sh #{node['jenkinselb']} build-deploy-platform-service  #{node['bitbucketelb']}  #{node['region']} #{node['jenkins']['SSH_user']}"
end
execute 'job_cleanup_cloudfront_distributions' do
  command "/home/#{node['jenkins']['SSH_user']}/cookbooks/jenkins/files/jobs/job_cleanup_cloudfront_distributions.sh #{node['jenkinselb']} cleanup_cloudfront_distributions  #{node['bitbucketelb']} #{node['jenkins']['SSH_user']}"
end
execute 'job_deploy-all-platform-services' do
  command "/home/#{node['jenkins']['SSH_user']}/cookbooks/jenkins/files/jobs/job_deploy-all-platform-services.sh #{node['jenkinselb']} deploy-all-platform-services #{node['bitbucketelb']}  #{node['region']} #{node['jenkins']['SSH_user']}"
end
execute 'createJob-job-pack-lambda' do
  command "/home/#{node['jenkins']['SSH_user']}/cookbooks/jenkins/files/jobs/job_build_pack_lambda.sh #{node['jenkinselb']} build-pack-lambda #{node['bitbucketelb']} #{node['jenkins']['SSH_user']}"
end

execute 'createJob-job-build-pack-website' do
  command "/home/#{node['jenkins']['SSH_user']}/cookbooks/jenkins/files/jobs/job_build_pack_website.sh #{node['jenkinselb']} build-pack-website #{node['bitbucketelb']} #{node['jenkins']['SSH_user']}"
end

link '/usr/bin/aws-api-import' do
  to "/home/#{node['jenkins']['SSH_user']}/jazz-core/aws-apigateway-importer/aws-api-import.sh"
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
  command "/home/#{node['jenkins']['SSH_user']}/cookbooks/jenkins/files/node/configureJenkinsProps.sh #{node['jenkinselb']} #{node['jenkins']['SSH_user']}"
end

execute 'configJenkinsLocConfigXml' do
  command "/home/#{node['jenkins']['SSH_user']}/cookbooks/jenkins/files/node/configJenkinsLocConfigXml.sh  #{node['jenkinselb']} #{node['jenkins']['SES-defaultSuffix']} #{node['jenkins']['SSH_user']}"
end

execute 'configJenkinsEmailExtXml' do
  command "/home/#{node['jenkins']['SSH_user']}/cookbooks/jenkins/files/node/configJenkinsEmailExtXml.sh #{node['jenkins']['SES-defaultSuffix']} #{node['jenkins']['SES-smtpAuthUsername']} #{node['jenkins']['SES-smtpAuthPassword']} #{node['jenkins']['SES-smtpHost']} #{node['jenkins']['SES-useSsl']} #{node['jenkins']['SES-smtpPort']} #{node['jenkinselb']} #{node['jenkins']['SSH_user']}"
end

execute 'configJenkinsTaskMailerXml' do
  command "/home/#{node['jenkins']['SSH_user']}/cookbooks/jenkins/files/node/configJenkinsTaskMailerXml.sh #{node['jenkins']['SES-smtpAuthUsername']} #{node['jenkins']['SES-smtpAuthPassword']} #{node['jenkins']['SES-smtpHost']} #{node['jenkins']['SES-useSsl']} #{node['jenkinselb']} #{node['jenkins']['SSH_user']}"
end

execute 'copyJenkinsPropertyfile' do
  command "cp #{node['jenkins']['propertyfile']} #{node['jenkins']['propertyfiletarget']};chmod 777  #{node['jenkins']['propertyfiletarget']}"
  cwd "/home/#{node['jenkins']['SSH_user']}"
end
execute 'chownJenkinsfolder' do
  command "chown jenkins:jenkins /var/lib/jenkins"
end

service "jenkins" do
  supports [:stop, :start, :restart]
  action [:restart]
end
execute 'copyJobBuildPackApi' do
  command "sleep 20;/home/#{node['jenkins']['SSH_user']}/cookbooks/jenkins/files/jobs/copyJob.sh #{node['jenkinselb']} build_pack_api build_pack_api_dev #{node['jenkins']['SSH_user']}"
end
execute 'copyJobBuildPackLambda' do
  command "sleep 20;/home/#{node['jenkins']['SSH_user']}/cookbooks/jenkins/files/jobs/copyJob.sh #{node['jenkinselb']} build-pack-lambda build-pack-lambda-dev #{node['jenkins']['SSH_user']}"
end
execute 'copyJobBuildPackLambda' do
  command "sleep 20;/home/#{node['jenkins']['SSH_user']}/cookbooks/jenkins/files/jobs/copyJob.sh #{node['jenkinselb']} build-pack-website build-pack-website-dev #{node['jenkins']['SSH_user']}"
end
