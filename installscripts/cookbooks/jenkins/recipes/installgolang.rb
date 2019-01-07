if node['dockerizedJenkins'] == false
    # Installing go lang
    remote_file "#{Chef::Config['file_cache_path']}/go1.10.3.linux-amd64.tar.gz" do
        source 'https://dl.google.com/go/go1.10.3.linux-amd64.tar.gz'
        mode '0755'
        action :create
    end

    execute 'mkdir' do
        command 'mkdir -p /opt/go/{bin,src,pkg}'
    end

    execute 'install_go' do
        command "tar -C /usr/local -xzf #{Chef::Config['file_cache_path']}/go1.10.3.linux-amd64.tar.gz"
    end

    # Installing godep (Dependency Management tool)
    remote_file "#{Chef::Config['file_cache_path']}/install.sh" do
        source 'https://raw.githubusercontent.com/golang/dep/master/install.sh'
        mode '0755'
        action :create
    end

    execute 'install_godep' do
        environment ({
            'GOPATH' => "/opt/go",
            'PATH' => "#{ENV['PATH']}:"+"#{ENV['GOPATH']}"+"/bin:"+"/usr/local/go/bin/"
        })
        command "bash #{Chef::Config['file_cache_path']}/install.sh"
    end
    # link go
    link '/bin/go' do
        to '/usr/local/go/bin/go'
    end
    # link dep
    link '/bin/dep' do
        to '/opt/go/bin/dep'
    end
end

