remote_file "#{Chef::Config['file_cache_path']}/sonar-scanner-cli-3.0.3.778-linux.zip" do
  source 'https://sonarsource.bintray.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-3.0.3.778-linux.zip'
  mode '0755'
  action :create
end

execute 'install_sonarscanner' do
  command "unzip -o #{Chef::Config['file_cache_path']}/sonar-scanner-cli-3.0.3.778-linux.zip"
  cwd '/opt'
end

directory '/opt/sonar-scanner-3.0.3.778-linux/' do
  owner 'jenkins'
  group 'jenkins'
  recursive true
end

link '/opt/sonar-scanner-3.0.3.778-linux/bin/sonar-scanner' do
  to '/bin/sonar-scanner'
end

directory '/var/log/depcheck_jazz/nistfiles' do
  owner 'jenkins'
  group 'jenkins'
  recursive true
end

remote_file "#{Chef::Config['file_cache_path']}/dependency-check-3.2.1-release.zip" do
  source 'https://bintray.com/jeremy-long/owasp/download_file?file_path=dependency-check-3.2.1-release.zip'
  mode '0755'
  action :create
end

execute 'install_dependency_check' do
  command "unzip -o #{Chef::Config['file_cache_path']}/dependency-check-3.2.1-release.zip"
  cwd '/opt'
end

directory '/opt/depency-check' do
  owner 'jenkins'
  group 'jenkins'
  recursive true
end

link '/opt/dependency-check/bin/dependency-check.sh' do
  to '/bin/dependency-check.sh'
end

remote_file '/opt/checkstyle-7.6-all.jar' do
  source 'https://downloads.sourceforge.net/checkstyle/OldFiles/7.6/checkstyle-7.6-all.jar'
  mode '0755'
  action :create
end
