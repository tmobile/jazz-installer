#prerequisites
apt_update 'update' #force-update apt cache on Debian-derivatives to avoid pkg fetch errors
package 'git'
include_recipe 'maven::default'
include_recipe 'nodejs'
include_recipe 'cloudcli'

npm_package 'serverless' do
  version '1.30.0'
end

npm_package '@angular/cli' do
  version '1.7.3'
end

npm_package 'jshint'

# plugin management
# Fetch the plugins.tar from our content repo TODO replace this with a dynamic plugin install like the dockerized version
execute 'copyPluginsTar' do
  command "curl -sL #{node['git_content_repo']}/#{node['git_plugin_branch']}/#{node['git_content_plugins']} -o #{node['chef_root']}/plugins.tar; chmod 755 #{node['chef_root']}/plugins.tar"
end

execute 'extractJenkinsPlugins' do
  command "tar -xf #{node['chef_root']}/plugins.tar -C #{node['jenkins']['home']}/"
end

# Clean up the plugin tar from previous step, it is rather large
file "#{node['chef_root']}/plugins.tar" do
  action :delete
end

service 'jenkins' do
  action :restart
end

# Wait a bit, Java apps don't coldboot very quickly...
execute 'waitForFirstJenkinsRestart' do
  command 'sleep 30'
end

# Copy authfile
cookbook_file "#{node['chef_root']}/authfile" do
  source 'authfile'
  action :create
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

# Try to fetch the version-appropriate Jenkins CLI jar from the server itself.
execute 'copyJenkinsClientJar' do
  command "curl -sL http://#{node['jenkinselb']}/jnlpJars/jenkins-cli.jar -o #{node['chef_root']}/jenkins-cli.jar; chmod 755 #{node['jenkins']['clientjar']}"
end
