if node['dockerizedJenkins'] == false
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

end
