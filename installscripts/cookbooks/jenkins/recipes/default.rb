yum_repository 'jenkins' do
  description 'jenkins'
  baseurl 'http://pkg.jenkins.io/redhat'
  gpgkey 'https://pkg.jenkins.io/redhat-stable/jenkins.io.key'
  action :create
end

yum_package 'jenkins' do
  action :install
  flush_cache [ :before ]
end

execute 'installplugins' do
  command "tar -xf /home/#{node['jenkins']['SSH_user']}/cookbooks/jenkins/files/plugins/plugins.tar"
  cwd '/var/lib/jenkins/'
end

execute 'installpip' do
  command "curl -O https://bootstrap.pypa.io/get-pip.py&& sudo python get-pip.py"
  cwd '/var/lib/jenkins/'
end

execute 'addpermissions' do
  command "chmod -R o+w /usr/lib/python2.7/site-packages/ /usr/bin/"
  cwd '/var/lib/jenkins/'
end

service "jenkins" do
  supports [:stop, :start, :restart]
  action [:stop]
end
execute 'copyProfileAndRcfiletoJenkinshome' do
  command "sudo cp /home/#{node['jenkins']['SSH_user']}/.bash_profile /var/lib/jenkins; sudo cp /home/#{node['jenkins']['SSH_user']}/.bashrc /var/lib/jenkins"
  cwd '/var/lib/jenkins/'
end


