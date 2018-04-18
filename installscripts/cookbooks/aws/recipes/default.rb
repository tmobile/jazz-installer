package "unzip"

remote_file "/tmp/awscli-bundle.zip" do
  source "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip"
  mode '0755'
  action :create
end

execute 'unzipaws' do
  command 'unzip -o awscli-bundle.zip'
   cwd '/tmp'
 end

execute 'installaws' do
  command './awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws'
  cwd '/tmp'
  ignore_failure true
end

execute 'installaws-apigateway-importer' do
   command 'npm i aws-apigateway-importer'
   #cwd "/usr/local"
end
