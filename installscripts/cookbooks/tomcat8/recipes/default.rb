#
# Cookbook Name:: tomcat8
# Recipe:: default
#
# Copyright 2016, Franklin American Mortgage Company
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe 'java'

tmp_path = Chef::Config[:file_cache_path]

#Download tomcat archive
remote_file "#{tmp_path}/tomcat8.tar.gz" do
  source node['tomcat8']['download_url']
  owner node['tomcat8']['tomcat_user']
  mode '0644'
  action :create
end

#create tomcat install dir
directory node['tomcat8']['install_location'] do
  owner node['tomcat8']['tomcat_user']
  mode '0755'
  action :create
end

#Extract the tomcat archive to the install location
bash 'Extract tomcat archive' do
  user node['tomcat8']['tomcat_user']
  cwd node['tomcat8']['install_location']
  code <<-EOH
    tar -zxvf #{tmp_path}/tomcat8.tar.gz --strip 1
  EOH
  action :run
end

#Install server.xml from template
template "#{node['tomcat8']['install_location']}/conf/server.xml" do
  source 'server.xml.erb'
  owner node['tomcat8']['tomcat_user']
  mode '0644'
end

#Install init script
template "/etc/init.d/tomcat8" do
  source 'tomcat8.erb'
  owner 'root'
  mode '0755'
end

#Start and enable tomcat service if requested
service 'tomcat8' do
  action [:enable, :start]
  only_if { node['tomcat8']['autostart'] }
end
