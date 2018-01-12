

execute 'startBitbucketServer' do
  command "sudo #{node['bitbucket']['startCommand']} --no-search "
end
