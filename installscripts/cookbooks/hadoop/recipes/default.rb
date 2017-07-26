#
# Cookbook Name:: hadoop
# Recipe:: default
#
# Copyright 2017, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
yum_package 'openssh-server'
yum_package 'openssh-clients'

remote_file '/tmp/hadoop-2.8.0.tar.gz' do
  source 'http://www.gtlib.gatech.edu/pub/apache/hadoop/common/hadoop-2.8.0/hadoop-2.8.0.tar.gz'
  mode '0755'
end
bash 'extract_module' do
  code <<-EOH
    tar xzf /tmp/hadoop-2.8.0.tar.gz -C /usr
    EOH
end

