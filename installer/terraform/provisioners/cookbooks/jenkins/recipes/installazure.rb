# Installing azcopy
remote_file "#{Chef::Config['file_cache_path']}/azurecopy.tar.gz" do
    source 'https://aka.ms/downloadazcopy-v10-linux'
    mode '0755'
    action :create
end

execute 'install_azcopy' do
    command "tar -C /opt -xzf #{Chef::Config['file_cache_path']}/azurecopy.tar.gz"
end

link '/bin/azcopy' do
  to '/opt/azcopy_linux_amd64_10.2.1/azcopy'
end

# Installing azure cli
yum_repository 'azurecli' do
  description 'Azure CLI'
  baseurl 'https://packages.microsoft.com/yumrepos/azure-cli'
  gpgkey 'https://packages.microsoft.com/keys/microsoft.asc'
  action :create
end

yum_package 'azure-cli' do
  action :install
end
