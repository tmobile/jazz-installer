package "unzip"

if node[:platform_family].include?("rhel")
  execute 'getnode' do
     command 'curl --silent --location https://rpm.nodesource.com/setup_8.x | bash -'
     #cwd "/usr/local"
  end
  execute 'installnodeandnpm' do
     command 'yum -y install nodejs-8.1.3'
     #cwd "/usr/local"
  end
end

if node[:platform_family].include?("debian")
  execute 'getnode' do
     command 'curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -'
  end
  execute 'installnodeandnpm' do
     command 'sudo apt-get install -y nodejs'
  end
end

execute 'npmversion' do
   command 'npm --version; node --version'
   #cwd "/usr/local"
end
execute 'installserverless' do
   command 'npm config set unsafe-perm=true; npm install -g serverless@1.26.1'
   cwd "/usr/local"
end
execute 'setup permissions for symbol-observable node module' do
   command 'sudo chmod -R o+r /usr/lib/node_modules/serverless/node_modules/symbol-observable/'
end
execute 'install ng-cli' do
   command 'sudo npm install -g @angular/cli@1.7.3'
end
execute 'install jshint' do
   command 'sudo npm install -g jshint'
end
remote_file '/tmp/sonar-scanner-cli-3.0.3.778-linux.zip' do
  source 'https://sonarsource.bintray.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-3.0.3.778-linux.zip'
  mode '0755'
  action :create
end
execute 'install_sonarscanner' do
  command 'unzip /tmp/sonar-scanner-cli-3.0.3.778-linux.zip'
  cwd '/opt'
end
execute 'setup permissions for sonar scanner' do
   command 'sudo chown -R jenkins:jenkins /opt/sonar-scanner-3.0.3.778-linux/'
end
execute 'createsymlink' do
  command 'sudo ln -sf /opt/sonar-scanner-3.0.3.778-linux/bin/sonar-scanner /bin/sonar-scanner'
end
execute 'dependency_folder' do
  command 'mkdir depcheck_jazz'
  cwd '/var/log'
end
execute 'dependency_folder_nistfiles' do
  command 'mkdir nistfiles'
  cwd '/var/log/depcheck_jazz'
end
execute 'setup permissions for dependency check log' do
   command 'sudo chown -R jenkins:jenkins /var/log/depcheck_jazz/'
end
remote_file '/tmp/dependency-check-3.2.1-release.zip' do
  source 'https://bintray.com/jeremy-long/owasp/download_file?file_path=dependency-check-3.2.1-release.zip'
  mode '0755'
  action :create
end
execute 'install_dependency_check' do
  command 'unzip /tmp/dependency-check-3.2.1-release.zip'
  cwd '/opt'
end
execute 'setup permissions for dependency check' do
   command 'sudo chown -R jenkins:jenkins /opt/dependency-check/'
end
execute 'createsymlink' do
  command 'sudo ln -sf /opt/dependency-check/bin/dependency-check.sh /bin/dependency-check.sh'
end
remote_file '/tmp/checkstyle-7.6-all.jar' do
  source 'https://downloads.sourceforge.net/checkstyle/OldFiles/7.6/checkstyle-7.6-all.jar'
  mode '0755'
  action :create
end
execute 'copy_checkstyle_jar' do
  command 'cp /tmp/checkstyle-7.6-all.jar .'
  cwd '/opt'
end
