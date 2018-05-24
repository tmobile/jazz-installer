python_runtime '2'
package 'git'
include_recipe 'maven::default'
include_recipe 'nodejs'
include_recipe 'cloudcli'

npm_package 'serverless' do
  version '1.26.1'
end

npm_package '@angular/cli' do
  version '1.7.3'
end
