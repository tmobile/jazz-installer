# Install python3 runtime
bash 'install-python3' do
  code <<-EOH
  version=$(python3 -V 2>&1 | grep -Po '(?<=Python )(.+)')
  if [[ -z "$version" ]]
  then
      yum install -y gcc
      yum install -y zlib-devel
      wget -O /opt/Python-3.8.0.tgz https://www.python.org/ftp/python/3.8.0/Python-3.8.0.tgz && tar xvzf /opt/Python-3.8.0.tgz -C /opt && cd /opt/Python-3.8.0 && ./configure && make && make install && rm /opt/Python-3.8.0.tgz
  fi  
  EOH
end

#link python3
link '/usr/bin/python3' do
  to '/usr/local/bin/python3'
end
# link pip3
link '/usr/bin/pip3' do
  to '/usr/bin/pip3.8'
end
