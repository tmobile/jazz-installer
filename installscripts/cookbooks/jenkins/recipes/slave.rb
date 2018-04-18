execute 'chmodservices' do
  command "chmod -R 755 /home/#{node['jenkins']['SSH_user']}/cookbooks/jenkins/files"
  cwd "/home/#{node['jenkins']['SSH_user']}"
end
directory '/var/lib/jenkins/workspace' do
  owner "#{node['jenkins']['SSH_user']}"
  group 'root'
  mode '0777'
  recursive true
  action :create
end
execute 'chmodfolders' do
  command "chmod -R 755 /var/lib/jenkins/workspace"
  cwd "/home/#{node['jenkins']['SSH_user']}"
end

execute 'downloadJenkinsClient' do
  command "sleep 20;curl -L #{node['client']['url']} -o #{node['client']['jar']}"
  cwd "/home/#{node['jenkins']['SSH_user']}"
end
execute 'configurenode' do
  command "#{node['node']['configurescript']} #{node['server']['privateip']} jenkins1"
  cwd "/home/#{node['jenkins']['SSH_user']}"
end

execute 'downloadgitproj' do
  command "/usr/local/git/bin/git clone -b Alpha-R1 #{node['jenkins']['git_repo']} jazz-core"
  cwd "/home/#{node['jenkins']['SSH_user']}"
end
execute 'runAwsgatewayImporter' do
  command "/opt/apache-maven-3.5.0/bin/mvn assembly:assembly"
  cwd "/home/#{node['jenkins']['SSH_user']}/jazz-core/aws-apigateway-importer"
end

link '/usr/bin/aws-api-import' do
  to "/home/#{node['jenkins']['SSH_user']}/jazz-core/aws-apigateway-importer/aws-api-import.sh"
  owner 'jenkins'
  group 'jenkins'
  mode '0777'
end
execute 'copylinkdir' do
  command "cp -rf /home/#{node['jenkins']['SSH_user']}/jazz-core/aws-apigateway-importer /tmp; chmod -R 777 /tmp/aws-apigateway-importer"
end

execute 'copyJenkinsPropertyfile' do
  command "cp #{node['jenkins']['propertyfile']} #{node['jenkins']['propertyfiletarget']};chmod 777  #{node['jenkins']['propertyfiletarget']}"
  cwd "/home/#{node['jenkins']['SSH_user']}"
end
