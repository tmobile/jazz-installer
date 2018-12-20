# Installing golang 
remote_file "#{Chef::Config['file_cache_path']}/go1.10.3.linux-amd64.tar.gz" do
    source 'https://dl.google.com/go/go1.10.3.linux-amd64.tar.gz'
    mode '0755'
    action :create
end
   
   
bash 'update_paths' do
    code <<-EOH
    tar -C /usr/local -xzf #{Chef::Config['file_cache_path']}/go1.10.3.linux-amd64.tar.gz
    echo 'export GOROOT=/usr/local/go' | sudo tee -a /etc/profile
    echo 'export GOBIN=$GOROOT/bin' | sudo tee -a /etc/profile
    echo 'export GOPATH=$GOROOT/src' | sudo tee -a /etc/profile
    echo 'export PATH=$PATH:$GOPATH:$GOBIN' | sudo tee -a /etc/profile
    source /etc/profile
    EOH
end
   
# Installing godep (Dependency Management tool) 
remote_file "#{Chef::Config['file_cache_path']}/install.sh" do
    source 'https://raw.githubusercontent.com/golang/dep/master/install.sh'
    mode '0755'
    action :create
end
   
execute 'install_godep' do
    command "sh #{Chef::Config['file_cache_path']}/install.sh" 
end
   



