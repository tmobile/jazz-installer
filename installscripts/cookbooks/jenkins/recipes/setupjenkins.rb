if node['dockerizedJenkins'] == false
  #prerequisites
  apt_update 'update' #force-update apt cache on Debian-derivatives to avoid pkg fetch errors
  package 'git'
  include_recipe 'maven::default'
  include_recipe 'nodejs'
  include_recipe 'cloudcli'

  npm_package 'serverless' do
    version '1.26.1'
  end

  npm_package '@angular/cli' do
    version '1.7.3'
  end

  npm_package 'jshint'

  #plugin management
  execute 'concatJenkinsPlugins' do
    command "cat #{node['chef_root']}/jenkinsplugins/plugins0* > #{node['chef_root']}/plugins.tar"
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
