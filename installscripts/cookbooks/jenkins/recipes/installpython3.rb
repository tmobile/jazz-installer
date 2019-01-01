if node['dockerizedJenkins'] == false
  # Install python3 runtime 
  bash 'install-python3' do
    code <<-EOH
    yum install -y https://centos7.iuscommunity.org/ius-release.rpm
    yum update
    yum install -y python36u python36u-libs python36u-devel python36u-pip
    EOH
  end
  
  #link python3
  link '/usr/bin/python3' do
    to '/usr/bin/python3.6'
  end
  # link pip3
  link '/usr/bin/pip3' do
    to '/usr/bin/pip3.6'
  end
end  