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
  command "/usr/local/git/bin/git clone -b Alpha-R1 #{node['jenkins']['git_repo']} jazz-core --depth 1"
  cwd "/home/#{node['jenkins']['SSH_user']}"
end

execute 'copyJenkinsPropertyfile' do
  command "cp #{node['jenkins']['propertyfile']} #{node['jenkins']['propertyfiletarget']};chmod 777  #{node['jenkins']['propertyfiletarget']}"
  cwd "/home/#{node['jenkins']['SSH_user']}"
end
