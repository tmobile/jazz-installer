#
# Cookbook Name:: aws
# Recipe:: default
#
# Copyright 2017, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
yum_package 'unzip' do
  action :install
end

remote_file "/tmp/awscli-bundle.zip" do
  source "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip"
  mode '0755'
  action :create
end

execute 'installaws' do
  command 'sudo pip install awscli --upgrade --ignore-installed'
  cwd '/tmp'
end

execute 'installaws-apigateway-importer' do
   command 'npm i aws-apigateway-importer'
   #cwd "/usr/local"
end
