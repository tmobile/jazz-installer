# TODO go thru all the scripts invoked here and make sure they don't assume HOME or SSH_USER

# Make current user owner of these files
execute 'chownjenkinsfiles' do
  command "sudo chown -R $USER #{node['cookbook_root']}/jenkins/files"
end

# Add execute bit to all shell scripts
execute 'chmodjenkinsscripts' do
  command "find #{node['cookbook_root']}/jenkins/files -type f -iname \"*.sh\" -exec chmod +x {} \;"
end

directory '/var/lib/jenkins/workspace' do
  owner 'jenkins'
  group 'jenkins'
  mode '0777'
  recursive true
end

# If we're on RHEL, adjust Java memory options
# (not sure if this is needed, or actually RHEL-specific, but keeping it)
if node[:platform_family].include?("rhel")
  execute 'resizeJenkinsMemorySettings' do
    command "sudo sed -i 's/JENKINS_JAVA_OPTIONS=.*.$/JENKINS_JAVA_OPTIONS=\"-Djava.awt.headless=true -Xmx1024m -XX:MaxPermSize=512m\"/' /etc/sysconfig/jenkins"
  end
end

service "jenkins" do
  action :start
end

# TODO This is different in orig script, figure out why
# Try to fetch the version-appropriate Jenkins CLI jar from the server itself.
execute 'copyJenkinsClientJar' do
  # command "cp #{node['client']['jar']} /home/#{node['jenkins']['SSH_user']}/jenkins-cli.jar; chmod 755 /home/#{node['jenkins']['SSH_user']}/jenkins-cli.jar"
  command "curl -sL http://#{node['jenkinselb']}/jnlpJars/jenkins-cli.jar -o #{node['chef_root']}/jenkins-cli.jar; chmod 755 #{node['chef_root']}/jenkins-cli.jar"
end

execute 'createJobExecUser' do
  command "sleep 30;echo 'jenkins.model.Jenkins.instance.securityRealm.createAccount(\"jobexec\", \"jenkinsadmin\")' | java -jar #{node['client']['jar']} -auth @#{node['authfile']} -s http://#{node['jenkinselb']}/ groovy ="
end

execute 'copyEncryptGroovyScript' do
  command "cp #{node['cookbook_root']}/jenkins/files/default/encrypt.groovy #{node['chef_root']}/encrypt.groovy"
end

execute 'copyXmls' do
  command "tar -xvf #{node['cookbook_root']}/jenkins/files/default/xmls.tar"
  cwd "/var/lib/jenkins"
end

execute 'copyConfigXml' do
  command "cp #{node['cookbook_root']}/cookbooks/jenkins/files/node/config.xml ."
  cwd "/var/lib/jenkins"
end

execute 'copyCredentialsXml' do
  command "#{node['cookbook_root']}/jenkins/files/credentials/credentials.xml ."
  cwd "/var/lib/jenkins"
end

# script approvals going in with  xmls.tar will be overwritten
execute 'copyScriptApprovals' do
  command "cp #{node['jenkins']['scriptApprovalfile']} #{node['jenkins']['scriptApprovalfiletarget']}"
end

# Configure Gitlab Plugin
execute 'configuregitlabplugin' do
  only_if  { node[:scm] == 'gitlab' }
  command "#{node['cookbook_root']}/jenkins/files/node/configuregitlab.sh #{node['scmelb']}"
end

execute 'configuregitlabuser' do
  only_if  { node[:scm] == 'gitlab' }
  command "#{node['cookbook_root']}/jenkins/files/credentials/gitlab-user.sh #{node['jenkinselb']} #{node['jenkins']['SSH_user']}"
end

execute 'configuregitlabtoken' do
  only_if  { node[:scm] == 'gitlab' }
  command "#{node['cookbook_root']}/jenkins/files/credentials/gitlab-token.sh #{node['jenkinselb']} #{node['jenkins']['SSH_user']}"
end

#TODO we do this at the end, do we need it here?
service "jenkins" do
  supports [:stop, :start, :restart]
  action [:restart]
end

directory "#{node['chef_root']}/jazz-core" do
  action :delete
end

git "#{node['chef_root']}/jazz-core" do
  repository "#{node['git_repo']}"
  reference "#{node['git_branch']}"
  action :sync
end

execute 'copylinkdir' do
  command "cp -rf #{node['chef_root']}/jazz-core/aws-apigateway-importer /var/lib; chmod -R 777 /var/lib/aws-apigateway-importer"
end

execute 'createcredentials-jenkins1' do
  only_if  { node[:scm] == 'bitbucket' }
  command "sleep 300;#{node['cookbook_root']}/jenkins/files/credentials/jenkins1.sh #{node['jenkinselb']} #{node['jenkins']['SSH_user']}"
end

execute 'createcredentials-jobexecutor' do
  command "#{node['cookbook_root']}/jenkins/files/credentials/jobexec.sh #{node['jenkinselb']} #{node['jenkins']['SSH_user']}"
end

execute 'createcredentials-aws' do
  command "#{node['cookbook_root']}/jenkins/files/credentials/aws.sh #{node['jenkinselb']} #{node['jenkins']['SSH_user']}"
end

execute 'createcredentials-cognitouser' do
  command "sleep 30;#{node['cookbook_root']}/jenkins/files/credentials/cognitouser.sh #{node['jenkinselb']} #{node['jenkins']['SSH_user']}"
end

execute 'configJenkinsLocConfigXml' do
  command "#{node['cookbook_root']}/jenkins/files/node/configJenkinsLocConfigXml.sh  #{node['jenkinselb']} #{node['jenkins']['SES-defaultSuffix']}"
end

execute 'createJob-create-service' do
  command "#{node['cookbook_root']}/jenkins/files/jobs/job_create-service.sh #{node['jenkinselb']} create-service #{node['scmpath']} #{node['jenkins']['SSH_user']}"
end

execute 'createJob-delete-service' do
  command "#{node['cookbook_root']}/jenkins/files/jobs/job_delete-service.sh #{node['jenkinselb']} delete-service #{node['scmpath']} #{node['jenkins']['SSH_user']}"
end

execute 'createJob-job_build_pack_api' do
  command "#{node['cookbook_root']}/jenkins/files/jobs/job_build_pack_api.sh #{node['jenkinselb']} build_pack_api #{node['scmpath']} #{node['jenkins']['SSH_user']}"
end

execute 'createJob-bitbucketteam_newService' do
  only_if  { node[:scm] == 'bitbucket' }
  command "#{node['cookbook_root']}/jenkins/files/jobs/job_bitbucketteam_newService.sh #{node['jenkinselb']} Jazz_User_Services #{node['scmelb']}  #{node['jenkins']['SSH_user']}"
end

execute 'createJob-platform_api_services' do
  only_if  { node[:scm] == 'bitbucket' }
  command "#{node['cookbook_root']}/jenkins/files/jobs/job_platform_api_services.sh #{node['jenkinselb']} Jazz_Core_Services #{node['scmelb']}  #{node['jenkins']['SSH_user']}"
end

execute 'job_cleanup_cloudfront_distributions' do
  command "#{node['cookbook_root']}/jenkins/files/jobs/job_cleanup_cloudfront_distributions.sh #{node['jenkinselb']} cleanup_cloudfront_distributions  #{node['scmpath']} #{node['jenkins']['SSH_user']}"
end

execute 'createJob-job-pack-lambda' do
  command "#{node['cookbook_root']}/jenkins/files/jobs/job_build_pack_lambda.sh #{node['jenkinselb']} build-pack-lambda #{node['scmpath']}  #{node['jenkins']['SSH_user']}"
end

execute 'createJob-job-build-pack-website' do
  command "#{node['cookbook_root']}/jenkins/files/jobs/job_build_pack_website.sh #{node['jenkinselb']} build-pack-website #{node['scmpath']}  #{node['jenkins']['SSH_user']}"
end

execute 'job-gitlab-trigger' do
  only_if  { node[:scm] == 'gitlab' }
  command "#{node['cookbook_root']}/jenkins/files/jobs/job-gitlab-trigger.sh #{node['jenkinselb']} #{node['jenkins']['SSH_user']} #{node['scmpath']}"
end

execute 'createJob-jazz_ui' do
  only_if  { node[:scm] == 'gitlab' }
  command "#{node['cookbook_root']}/jenkins/files/jobs/job_jazz_ui.sh #{node['jenkinselb']} root #{node['scmpath']}"
end

link '/usr/bin/aws-api-import' do
  to "#{node['chef_root']}/jazz-core/aws-apigateway-importer/aws-api-import.sh"
  owner 'jenkins'
  group 'jenkins'
  mode '0777'
end

directory '/var/lib/jenkins' do
  owner 'jenkins'
  group 'jenkins'
  action :create
end

service "jenkins" do
  supports [:stop, :start, :restart]
  action [:restart]
end
