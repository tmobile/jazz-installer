apt_update 'update' #force-update apt cache on Debian-derivatives to avoid pkg fetch errors
package 'git'
include_recipe 'maven::default'
include_recipe 'nodejs::nodejs_from_binary'
include_recipe 'cloudcli'

npm_package 'serverless' do
  version '1.26.1'
end

npm_package '@angular/cli' do
  version '1.7.3'
end
