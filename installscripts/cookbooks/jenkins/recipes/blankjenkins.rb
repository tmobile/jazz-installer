#
# Cookbook Name:: jenkins
# Recipe:: default
#
# Copyright 2017, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

execute 'chmodservices' do
  command "chmod -R 755 /home/ec2-user/cookbooks/jenkins/files;"
end
directory '/var/lib/jenkins/workspace' do
  owner 'jenkins'
  group 'jenkins'
  mode '0777'
  recursive true
  action :create
end
service "jenkins" do
  supports [:stop, :start, :restart]
  action [:start]
end
execute 'copyJenkinsClientJar' do
  command "cp #{node['client']['jar']} /home/ec2-user/jenkins-cli.jar; chmod 755 /home/ec2-user/jenkins-cli.jar"
end
execute 'createadmin' do
  command "sleep 30;echo 'jenkins.model.Jenkins.instance.securityRealm.createAccount(\"jenkinsadmin\", \"jenkinsadmin\")' | java -jar #{node['client']['jar']} -auth admin:`cat /var/lib/jenkins/secrets/initialAdminPassword` -s http://localhost:8080/ groovy ="
end
service "jenkins" do
  supports [:stop, :start, :restart]
  action [:restart]
end
