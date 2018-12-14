#
if node['dockerizedJenkins'] == false
  # Copy authfile
  cookbook_file "#{node['chef_root']}/authfile" do
    source 'authfile'
    action :create
  end
end

directory "#{node['jenkins']['home']}/workspace" do
  owner 'jenkins'
  group 'jenkins'
  mode '0777'
  recursive true
end

directory node['script_root'] do
  recursive true
end

# If we're on RHEL, adjust Java memory options
# (not sure if this is needed, or actually RHEL-specific, but keeping it)
execute 'resizeJenkinsMemorySettings' do
  only_if { node['platform_family'].include?('rhel') }
  command "sudo sed -i 's/JENKINS_JAVA_OPTIONS=.*.$/JENKINS_JAVA_OPTIONS=\"-Djava.awt.headless=true -Xmx1024m -XX:MaxPermSize=512m\"/' /etc/sysconfig/jenkins"
end


# Try to fetch the version-appropriate Jenkins CLI jar from the server itself.
execute 'copyJenkinsClientJar' do
  command "curl -sL http://#{node['jenkinselb']}/jnlpJars/jenkins-cli.jar -o #{node['chef_root']}/jenkins-cli.jar; chmod 755 #{node['jenkins']['clientjar']}"
end

bash 'createJobExecUser' do
  code <<-EOH
  echo 'jenkins.model.Jenkins.instance.securityRealm.createAccount(\"jobexec\", \"#{node["cognitopassword"]}\")' | java -jar #{node['jenkins']['clientjar']} -auth @#{node['authfile']} -s http://#{node['jenkinselb']}/ groovy =
  EOH
end

cookbook_file "#{node['chef_root']}/encrypt.groovy" do
  source 'encrypt.groovy'
  action :create
end

# Fetch the xmls.tar from our content repo
execute 'copyXmlsTar' do
  command "curl -sL #{node['git_content_repo']}/#{node['git_plugin_branch']}/#{node['git_content_xmls']} -o #{node['chef_root']}/xmls.tar; chmod 755 #{node['chef_root']}/xmls.tar"
end

#ToDo ChefRemoval
execute 'extractXmls' do
  command "tar -xvf #{node['chef_root']}/xmls.tar"
  cwd "#{node['jenkins']['home']}"
end

cookbook_file "#{node['jenkins']['home']}/config.xml" do
  source 'config.xml'
  action :create
end

cookbook_file "#{node['jenkins']['home']}/scriptApproval.xml" do
  source 'scriptApproval.xml'
  action :create
end

cookbook_file "#{node['jenkins']['home']}/credentials.xml" do
  source 'credentials.xml'
  action :create
end

bash 'configJenkinsLocConfigXml' do
  code <<-SCRIPT
  JENKINS_LOC_CONFIG_XML=#{node['jenkins']['home']}/jenkins.model.JenkinsLocationConfiguration.xml

  sed  -i "s=adminAddress.*.$=adminAddress>#{node['jenkins']['SES-defaultSuffix']}</adminAddress>=g" $JENKINS_LOC_CONFIG_XML
  sed  -i "s=jenkinsUrl.*.$=jenkinsUrl>http://#{node['jenkinselb']}/</jenkinsUrl>=g" $JENKINS_LOC_CONFIG_XML
  SCRIPT
end

# Optional Gitlab block
if node['scm'] == 'gitlab'

  # Configure Gitlab Plugin
  bash 'configuregitlabplugin' do
    code <<-SCRIPT
    sed -i "s/ip/#{node['scmelb']}/g" #{node['jenkins']['home']}/com.dabsquared.gitlabjenkins.connection.GitLabConnectionConfig.xml
  SCRIPT
  end

  #Copy and run gitlab-user script
  cookbook_file "#{node['script_root']}/gitlab-user.sh" do
    source 'credentials/gitlab-user.sh'
    mode 0755
  end

  execute 'configureGitlabuser' do
    command "#{node['script_root']}/gitlab-user.sh #{node['jenkins']['clicommand']} #{node['gitlabuser']} #{node['gitlabpassword']}"
  end

  #Copy and run gitlab-token script
  cookbook_file "#{node['script_root']}/gitlab-token.sh" do
    source 'credentials/gitlab-token.sh'
    mode 0755
  end

  execute 'configuregitlabtoken' do
    command "#{node['script_root']}/gitlab-token.sh #{node['jenkins']['clicommand']} #{node['gitlabtoken']}"
  end
end

# Optional Bitbucket block
if node['scm'] == 'bitbucket'

  #Copy and run bitbucket-creds script
  cookbook_file "#{node['script_root']}/bitbucket-creds.sh" do
    source 'credentials/bitbucket-creds.sh'
    mode 0755
  end

  execute 'createcredentials-bitbucket' do
    command "#{node['script_root']}/bitbucket-creds.sh #{node['jenkins']['clicommand']} #{node['bbuser']} #{node['bbpassword']}"
  end
end


# If this happens to already exist, remove it before we clone again.
directory "#{node['chef_root']}/jazz-core" do
  action :delete
end

# We only need a shallow clone
git "#{node['chef_root']}/jazz-core" do
  repository node['git_repo']
  reference node['git_branch']
  depth 1
  action :sync
end

# Set up jenkins job executor account
cookbook_file "#{node['script_root']}/jobexec.sh" do
  source 'credentials/jobexec.sh'
  mode 0755
end

execute 'createcredentials-jobexecutor' do
  command "#{node['script_root']}/jobexec.sh #{node['jenkins']['clicommand']}"
end

# Set up sonar
cookbook_file "#{node['script_root']}/sonar.sh" do
  source 'credentials/sonar.sh'
  mode 0755
end

execute 'createcredentials-sonar' do
  command "#{node['script_root']}/sonar.sh #{node['jenkins']['clicommand']} #{node['sonaruser']} #{node['sonarpassword']}"
end

#Set up AWS creds
cookbook_file "#{node['script_root']}/aws.sh" do
  source 'credentials/aws.sh'
  mode 0755
end

execute 'createcredentials-aws' do
  command "#{node['script_root']}/aws.sh #{node['jenkins']['clicommand']} #{node['aws_access_key']} #{node['aws_secret_key']}"
end

#Set up Cognito creds
cookbook_file "#{node['script_root']}/cognitouser.sh" do
  source 'credentials/cognitouser.sh'
  mode 0755
end

execute 'createcredentials-cognitouser' do
  command "#{node['script_root']}/cognitouser.sh #{node['jenkins']['clicommand']} #{node['cognitouser']} #{node['cognitopassword']}"
end

#Set up create-service job
cookbook_file "#{node['script_root']}/job_create-service.sh" do
  source 'jobs/job_create-service.sh'
  mode 0755
end

execute 'createJob-create-service' do
  command "#{node['script_root']}/job_create-service.sh #{node['jenkins']['clicommand']} #{node['scmpath']}"
end

#Set up delete-service job
cookbook_file "#{node['script_root']}/job_delete-service.sh" do
  source 'jobs/job_delete-service.sh'
  mode 0755
end

execute 'createJob-delete-service' do
  command "#{node['script_root']}/job_delete-service.sh #{node['jenkins']['clicommand']} #{node['scmpath']}"
end

#Set up build_pack_api job
cookbook_file "#{node['script_root']}/job_build_pack_api.sh" do
  source 'jobs/job_build_pack_api.sh'
  mode 0755
end

execute 'createJob-job_build_pack_api' do
  command "#{node['script_root']}/job_build_pack_api.sh #{node['jenkins']['clicommand']} #{node['scmpath']}"
end

#Set up cleanup_cloudfront_distributions job
cookbook_file "#{node['script_root']}/job_cleanup_cloudfront_distributions.sh" do
  source 'jobs/job_cleanup_cloudfront_distributions.sh'
  mode 0755
end

execute 'job_cleanup_cloudfront_distributions' do
  command "#{node['script_root']}/job_cleanup_cloudfront_distributions.sh #{node['jenkins']['clicommand']} #{node['scmpath']}"
end

# Set up build_pack_lambda job
cookbook_file "#{node['script_root']}/job_build_pack_lambda.sh" do
  source 'jobs/job_build_pack_lambda.sh'
  mode 0755
end

execute 'createJob-job-pack-lambda' do
  command "#{node['script_root']}/job_build_pack_lambda.sh #{node['jenkins']['clicommand']} #{node['scmpath']}"
end

# Set up build_pack_website job
cookbook_file "#{node['script_root']}/job_build_pack_website.sh" do
  source 'jobs/job_build_pack_website.sh'
  mode 0755
end

execute 'createJob-job-build-pack-website' do
  command "#{node['script_root']}/job_build_pack_website.sh #{node['jenkins']['clicommand']} #{node['scmpath']}"
end

# Set up jazz_ui job
cookbook_file "#{node['script_root']}/job_jazz_ui.sh" do
  source 'jobs/job_jazz_ui.sh'
  mode 0755
end

execute 'createJob-jazz_ui' do
  command "#{node['script_root']}/job_jazz_ui.sh #{node['jenkins']['clicommand']} #{node['scmpath']}"
end

directory "#{node['jenkins']['home']}" do
  owner 'jenkins'
  group 'jenkins'
  action :create
end
#Docker container has no service jenkins
if node['dockerizedJenkins'] == false
  service 'jenkins' do
    supports [:stop, :start, :restart]
    action [:restart]
  end
end
