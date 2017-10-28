#
# Cookbook Name:: maven
# Recipe:: default
#
# Copyright 2017, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

remote_file '/tmp/apache-maven-3.5.2-bin.tar.gz' do
  source 'http://mirror.olnevhost.net/pub/apache/maven/maven-3/3.5.2/binaries/apache-maven-3.5.2-bin.tar.gz'
  mode '0755'
  action :create
end
execute 'install_maven' do
  command 'tar xzvf /tmp/apache-maven-3.5.2-bin.tar.gz'
  cwd '/opt'
end

file '/etc/profile.d/maven.sh' do
  content "export PATH=$PATH:/opt/apache-maven-3.5.2/bin"
end
execute 'createsymlink' do
  command 'sudo ln -sf /opt/apache-maven-3.5.2/bin/mvn /usr/bin/mvn'
end


