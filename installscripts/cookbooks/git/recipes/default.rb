#
# Cookbook Name:: git
# Recipe:: default
#
# Copyright 2017, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
#yum_package 'git' do
#  action :install
#end
execute 'gitprereq' do
  command 'yum install -y curl-devel expat-devel gettext-devel openssl-devel zlib-devel'
  #cwd '~/'
end
execute 'gitprereq2' do
  command 'yum install -y gcc perl-ExtUtils-MakeMaker '
  #cwd '~/'
end
gitversion = node['git']['version']
#Chef::Application.fatal!(gitversion)
yum_package 'git' do
  options  '-y'
  action :remove
end
remote_file "/tmp/git-#{node['git']['version']}.tar.gz" do
  source "https://www.kernel.org/pub/software/scm/git/git-#{node['git']['version']}.tar.gz"
  mode '0755'
  action :create
end
execute 'untar' do
  command "tar xzf /tmp/git-#{node['git']['version']}.tar.gz"
  cwd '/usr/src'
end
execute 'makeall' do
  command 'make prefix=/usr/local/git all'
  cwd "/usr/src/git-#{node['git']['version']}"
end
execute 'makeinstall' do
   command 'make prefix=/usr/local/git install'
   cwd "/usr/src/git-#{node['git']['version']}"
end
execute 'setpath' do
   command 'export PATH=$PATH:/usr/local/git/bin'
   #cwd '~/'
end
#execute 'displayversion' do
 #  command 'source /etc/bashrc;git --version'
   #cwd '~/'
#end
file '/etc/profile.d/git.sh' do
   content "export PATH=$PATH:/usr/local/git/bin"
end
link '/usr/bin/git' do
  to '/usr/local/git/bin/git'
end


