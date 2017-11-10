#
# Cookbook Name:: jenkins
# Recipe:: default
#
# Copyright 2017, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
execute 'chmodservices' do
  command "chmod -R 755 /home/ec2-user/cookbooks/jenkins/files"
  cwd '/home/ec2-user'  
end
directory '/var/lib/jenkins/workspace' do
  owner 'ec2-user'
  group 'root'
  mode '0777'
  recursive true
  action :create
end
execute 'chmodfolders' do
  command "chmod -R 755 /var/lib/jenkins/workspace"
  cwd '/home/ec2-user'  
end

execute 'downloadJenkinsClient' do
  command "sleep 20;curl -L #{node['client']['url']} -o #{node['client']['jar']}"
  cwd '/home/ec2-user'
end
execute 'configurenode' do
  command "#{node['node']['configurescript']} #{node['server']['privateip']} jenkins1"
  cwd '/home/ec2-user'
end

execute 'downloadgitproj' do
  command "/usr/local/git/bin/git clone -b Alpha-R1 https://github.com/tmobile/jazz.git jazz-core"
  cwd '/home/ec2-user'
end
execute 'runAwsgatewayImporter' do
  command "/opt/apache-maven-3.5.0/bin/mvn assembly:assembly"
  cwd '/home/ec2-user/jazz-core/aws-apigateway-importer'
end

link '/usr/bin/aws-api-import' do
  to '/home/ec2-user/jazz-core/aws-apigateway-importer/aws-api-import.sh'
  owner 'jenkins'
  group 'jenkins'
  mode '0777'
end
execute 'copylinkdir' do
  command "cp -rf /home/ec2-user/jazz-core/aws-apigateway-importer /tmp; chmod -R 777 /tmp/aws-apigateway-importer"
end
execute 'configureJenkinsProperites' do
  command "/home/ec2-user/cookbooks/jenkins/files/node/configureJenkinsProps.sh #{node['server']['privateip']} "
  cwd '/home/ec2-user'
end

execute 'copyJenkinsPropertyfile' do
  command "cp #{node['jenkins']['propertyfile']} #{node['jenkins']['propertyfiletarget']};chmod 777  #{node['jenkins']['propertyfiletarget']}"
  cwd '/home/ec2-user'
end
