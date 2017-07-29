#
# Cookbook Name:: bitbucket
# Recipe:: default
#
# Copyright 2017, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
template "#{node['bitbucket']['responsefile']}" do
  source 'responsefile.erb'
  owner 'root'
  group 'root'
  mode '0755'
  variables(
    :bitbucketHome => node['bitbucket']['bitbucketHome'],
    :defaultInstallDir => node['bitbucket']['defaultInstallDir'],
    :installservice => node['bitbucket']['installservice'],
    :portChoice => node['bitbucket']['portChoice']
  )  
end

execute 'downloadbitbucketinstaller' do
  command "curl -L #{node['bitbucket']['installerUrl']} -o #{node['bitbucket']['installer']}"
end
execute 'chmodall' do
  command "chmod 755 #{node['bitbucket']['installer']}; chmod 755 #{node['bitbucket']['responsefile']}"
end
execute 'installbucket' do
  command "#{node['bitbucket']['installer']} -q -varfile #{node['bitbucket']['responsefile']}"
end