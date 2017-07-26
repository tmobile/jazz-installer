#
# Cookbook Name:: bitbucket
# Recipe:: default
#
# Copyright 2017, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#


execute 'startBitbucketServer' do
  command "sudo #{node['bitbucket']['startCommand']} --no-search "
end
