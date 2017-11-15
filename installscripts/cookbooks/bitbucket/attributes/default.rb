default['bitbucket']['responsefile']    = '/home/ec2-user/cookbooks/bitbucket/files/default/responsefile'
default['bitbucket']['installer']    = '/jazz_tmp/atlassian-bitbucket-5.0.2-x64.bin'
default['bitbucket']['installerUrl']    = 'https://www.atlassian.com/software/stash/downloads/binary/atlassian-bitbucket-5.0.2-x64.bin'
default['bitbucket']['bitbucketHome']    = '/home/ec2-user/atlassian/application-data/bitbucket'
default['bitbucket']['defaultInstallDir']    = '/home/ec2-user/atlassian/bitbucket/5.2'
default['bitbucket']['installservice'] = 'false'
default['bitbucket']['portChoice'] = 'default'

default['bitbucket']['propertiesfile'] = #{node['bitbucket']['bitbucketHome']}/shared/bitbucket.properties
default['bitbucket']['properties']['baseUrl'] = #{node['bitbucketelb.dns_name']}
default['bitbucket']['properties']['sysadmin.username'] = 'ustadmin'
default['bitbucket']['properties']['sysadmin.displayName'] = 'ustsysadmin'
default['bitbucket']['properties']['sysadmin.emailAddress'] = 'harin.jose@ust-global.com'
default['bitbucket']['startCommand']    = "#{node['bitbucket']['defaultInstallDir']}/bin/start-bitbucket.sh"

