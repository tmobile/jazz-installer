# Make current user owner of these files
execute 'chownjenkinsfiles' do
  command "sudo chown -R $(whoami) #{node['cookbook_root']}/jenkins/files"
end

# Add execute bit to all shell scripts
execute 'chmodjenkinsscripts' do
  command "find #{node['cookbook_root']}/jenkins/files -type f -iname \"*.sh\" -exec chmod +x {} \\;"
end

directory '/var/lib/jenkins/workspace' do
  owner 'jenkins'
  group 'jenkins'
  mode '0777'
  recursive true
end

# If we're on RHEL, adjust Java memory options
# (not sure if this is needed, or actually RHEL-specific, but keeping it)
if node['platform_family'].include?('rhel')
  execute 'resizeJenkinsMemorySettings' do
    command "sudo sed -i 's/JENKINS_JAVA_OPTIONS=.*.$/JENKINS_JAVA_OPTIONS=\"-Djava.awt.headless=true -Xmx1024m -XX:MaxPermSize=512m\"/' /etc/sysconfig/jenkins"
  end
end

service 'jenkins' do
  action :restart
end

# Wait a bit, Java apps don't coldboot very quickly...
execute 'waitForFirstJenkinsRestart' do
  command 'sleep 30'
end

# Try to fetch the version-appropriate Jenkins CLI jar from the server itself.
execute 'copyJenkinsClientJar' do
  command "curl -sL http://#{node['jenkinselb']}/jnlpJars/jenkins-cli.jar -o #{node['chef_root']}/jenkins-cli.jar; chmod 755 #{node['jenkins']['clientjar']}"
end

execute 'createJobExecUser' do
  command "echo 'jenkins.model.Jenkins.instance.securityRealm.createAccount(\"jobexec\", \"jenkinsadmin\")' | java -jar #{node['jenkins']['clientjar']} -auth @#{node['authfile']} -s http://#{node['jenkinselb']}/ groovy ="
end

execute 'copyEncryptGroovyScript' do
  command "cp #{node['cookbook_root']}/jenkins/files/default/encrypt.groovy #{node['chef_root']}/encrypt.groovy"
end

execute 'copyXmls' do
  command "tar -xvf #{node['cookbook_root']}/jenkins/files/default/xmls.tar"
  cwd '/var/lib/jenkins'
end

execute 'copyConfigXml' do
  command "cp #{node['cookbook_root']}/jenkins/files/node/config.xml ."
  cwd '/var/lib/jenkins'
end

execute 'copyCredentialsXml' do
  command "cp #{node['cookbook_root']}/jenkins/files/credentials/credentials.xml ."
  cwd '/var/lib/jenkins'
end

# script approvals going in with  xmls.tar will be overwritten
execute 'copyScriptApprovals' do
  command "cp #{node['jenkins']['scriptApprovalfile']} #{node['jenkins']['scriptApprovalfiletarget']}"
end

# Configure Gitlab Plugin
execute 'configuregitlabplugin' do
  only_if { node['scm'] == 'gitlab' }
  command "#{node['cookbook_root']}/jenkins/files/node/configuregitlab.sh #{node['scmelb']}"
end

execute 'configuregitlabuser' do
  only_if { node['scm'] == 'gitlab' }
  command "#{node['cookbook_root']}/jenkins/files/credentials/gitlab-user.sh #{node['jenkinselb']} #{node['jenkins']['clientjar']} #{node['authfile']}"
end

execute 'configuregitlabtoken' do
  only_if { node['scm'] == 'gitlab' }
  command "#{node['cookbook_root']}/jenkins/files/credentials/gitlab-token.sh #{node['jenkinselb']} #{node['jenkins']['clientjar']} #{node['authfile']}"
end

# TODO: we do this at the end, do we need it here?
service 'jenkins' do
  supports [:stop, :start, :restart]
  action [:restart]
end

# Wait a bit, Java apps don't coldboot very quickly...
execute 'waitForSecondJenkinsRestart' do
  command 'sleep 30'
end

directory "#{node['chef_root']}/jazz-core" do
  action :delete
end

git "#{node['chef_root']}/jazz-core" do
  repository node['git_repo']
  reference node['git_branch']
  depth 1
  action :sync
end

execute 'createcredentials-jenkins1' do
  only_if { node['scm'] == 'bitbucket' }
  command "#{node['cookbook_root']}/jenkins/files/credentials/jenkins1.sh #{node['jenkinselb']} #{node['jenkins']['clientjar']} #{node['authfile']}"
end

execute 'createcredentials-jobexecutor' do
  command "#{node['cookbook_root']}/jenkins/files/credentials/jobexec.sh #{node['jenkinselb']} #{node['jenkins']['clientjar']} #{node['authfile']}"
end

execute 'createcredentials-sonar' do
  command "#{node['cookbook_root']}/jenkins/files/credentials/sonar.sh #{node['jenkinselb']} #{node['jenkins']['clientjar']} #{node['authfile']}"
end

execute 'createcredentials-aws' do
  command "#{node['cookbook_root']}/jenkins/files/credentials/aws.sh #{node['jenkinselb']} #{node['jenkins']['clientjar']} #{node['authfile']}"
end

execute 'createcredentials-cognitouser' do
  command "#{node['cookbook_root']}/jenkins/files/credentials/cognitouser.sh #{node['jenkinselb']} #{node['jenkins']['clientjar']} #{node['authfile']}"
end

execute 'configJenkinsLocConfigXml' do
  command "#{node['cookbook_root']}/jenkins/files/node/configJenkinsLocConfigXml.sh  #{node['jenkinselb']} #{node['jenkins']['SES-defaultSuffix']}"
end

execute 'createJob-create-service' do
  command "#{node['cookbook_root']}/jenkins/files/jobs/job_create-service.sh #{node['jenkinselb']} #{node['jenkins']['clientjar']} #{node['authfile']} #{node['scmpath']}"
end

execute 'createJob-delete-service' do
  command "#{node['cookbook_root']}/jenkins/files/jobs/job_delete-service.sh #{node['jenkinselb']} #{node['jenkins']['clientjar']} #{node['authfile']} #{node['scmpath']}"
end

execute 'createJob-job_build_pack_api' do
  command "#{node['cookbook_root']}/jenkins/files/jobs/job_build_pack_api.sh #{node['jenkinselb']} #{node['jenkins']['clientjar']} #{node['authfile']} #{node['scmpath']}"
end

execute 'createJob-bitbucketteam_newService' do
  only_if { node['scm'] == 'bitbucket' }
  command "#{node['cookbook_root']}/jenkins/files/jobs/job_bitbucketteam_newService.sh #{node['jenkinselb']} #{node['jenkins']['clientjar']} #{node['authfile']} #{node['scmelb']}"
end

execute 'createJob-platform_api_services' do
  only_if { node['scm'] == 'bitbucket' }
  command "#{node['cookbook_root']}/jenkins/files/jobs/job_platform_api_services.sh #{node['jenkinselb']} #{node['jenkins']['clientjar']} #{node['authfile']} #{node['scmelb']}"
end

execute 'job_cleanup_cloudfront_distributions' do
  command "#{node['cookbook_root']}/jenkins/files/jobs/job_cleanup_cloudfront_distributions.sh #{node['jenkinselb']} #{node['jenkins']['clientjar']} #{node['authfile']} #{node['scmpath']}"
end

execute 'createJob-job-pack-lambda' do
  command "#{node['cookbook_root']}/jenkins/files/jobs/job_build_pack_lambda.sh #{node['jenkinselb']} #{node['jenkins']['clientjar']} #{node['authfile']} #{node['scmpath']}"
end

execute 'createJob-job-build-pack-website' do
  command "#{node['cookbook_root']}/jenkins/files/jobs/job_build_pack_website.sh #{node['jenkinselb']} #{node['jenkins']['clientjar']} #{node['authfile']} #{node['scmpath']}"
end

execute 'job-gitlab-trigger' do
  only_if { node['scm'] == 'gitlab' }
  command "#{node['cookbook_root']}/jenkins/files/jobs/job-gitlab-trigger.sh #{node['jenkinselb']} #{node['jenkins']['clientjar']} #{node['authfile']} #{node['scmpath']}"
end

execute 'createJob-jazz_ui' do
  only_if { node['scm'] == 'gitlab' }
  command "#{node['cookbook_root']}/jenkins/files/jobs/job_jazz_ui.sh #{node['jenkinselb']} #{node['jenkins']['clientjar']} #{node['authfile']} #{node['scmpath']}"
end

directory '/var/lib/jenkins' do
  owner 'jenkins'
  group 'jenkins'
  action :create
end

service 'jenkins' do
  supports [:stop, :start, :restart]
  action [:restart]
end
