#
# Cookbook Name:: npm
# Recipe:: default
#
# Copyright 2017, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
execute 'getnode' do
   command 'curl --silent --location https://rpm.nodesource.com/setup_8.x | bash -'
   #cwd "/usr/local"
end
execute 'installnodeandnpm' do
   command 'yum -y install nodejs-8.1.3'
   #cwd "/usr/local"
end
execute 'npmversion' do
   command 'npm --version; node --version'
   #cwd "/usr/local"
end
execute 'installserverless' do
   command 'npm config set unsafe-perm=true; npm install -g serverless'
   cwd "/usr/local"
end
execute 'setup permissions for symbol-observable node module' do
   command 'sudo chmod -R o+r /usr/lib/node_modules/serverless/node_modules/symbol-observable/'
end
