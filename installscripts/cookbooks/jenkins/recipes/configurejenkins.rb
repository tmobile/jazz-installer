
directory node['script_root'] do
  recursive true
end

# If we're on RHEL, adjust Java memory options
# (not sure if this is needed, or actually RHEL-specific, but keeping it)
execute 'resizeJenkinsMemorySettings' do
  only_if { node['platform_family'].include?('rhel') }
  command "sudo sed -i 's/JENKINS_JAVA_OPTIONS=.*.$/JENKINS_JAVA_OPTIONS=\"-Djava.awt.headless=true -Xmx1024m -XX:MaxPermSize=512m\"/' /etc/sysconfig/jenkins"
end

# If this happens to already exist, remove it before we clone again.
directory "#{node['chef_root']}/jazz-core" do
  action :delete
end

# We only need a shallow clone
git "#{node['chef_root']}/jazz-core" do
  repository node['git_repo']
  reference node['git_branch']
  depth 1
  action :sync
end

directory "#{node['jenkins']['home']}" do
  owner 'jenkins'
  group 'jenkins'
  action :create
end
#Docker container has no service jenkins
if node['dockerizedJenkins'] == false
  service 'jenkins' do
    supports [:stop, :start, :restart]
    action [:restart]
  end
end
