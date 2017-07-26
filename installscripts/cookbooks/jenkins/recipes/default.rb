#
# Cookbook Name:: jenkins
# Recipe:: default
#
# Copyright 2017, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
yum_repository 'jenkins' do
  description 'jenkins'
  baseurl 'http://pkg.jenkins.io/redhat'
  gpgkey 'https://pkg.jenkins.io/redhat-stable/jenkins.io.key'
  action :create
end

yum_package 'jenkins' do
  action :install
  flush_cache [ :before ]
end

execute 'installplugins' do
  command "tar -xf /home/ec2-user/cookbooks/jenkins/files/plugins/plugins.tar"
  cwd '/var/lib/jenkins/'
end

service "jenkins" do
  supports [:stop, :start, :restart]
  action [:stop]
end
execute 'copyProfileAndRcfiletoJenkinshome' do
  command "sudo cp /home/ec2-user/.bash_profile /var/lib/jenkins; sudo cp /home/ec2-user/.bashrc /var/lib/jenkins"
  cwd '/var/lib/jenkins/'
end


