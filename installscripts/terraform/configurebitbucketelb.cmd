set bitbucketelb_dns_name=%1
set chefconfigDir_bitbucketelbconfig_json=%2
set jenkinsattribsfile=%3
set jenkinspropertiesfile=%4
echo { "bitbucketelb.dns_name": "%bitbucketelb_dns_name%" } > %chefconfigDir_bitbucketelbconfig_json%
sed -i "s/default\['bitbucketelb'\].*.$/default['bitbucketelb']='%bitbucketelb_dns_name%'/g"  %jenkinsattribsfile%
sed -i 's/REPO_BASE=.*.$/REPO_BASE=%bitbucketelb_dns_name%:7990/g' %jenkinspropertiesfile%
REM removing as per vinays request on 07/12/2017- Its been taken care of another way
REM sed -i 's/"BIT_BUCKET_URL":".*.projects/"BIT_BUCKET_URL":"%bitbucketelb_dns_name%:7990\/projects/g' ./jazz-core/create-serverless-service/config/dev-config.json
REM sed -i 's/"BIT_BUCKET_URL":".*.projects/"BIT_BUCKET_URL":"%bitbucketelb_dns_name%:7990\/projects/g' ./jazz-core/create-serverless-service/config/prod-config.json
REM sed -i 's/"BIT_BUCKET_URL":".*.projects/"BIT_BUCKET_URL":"%bitbucketelb_dns_name%:7990\/projects/g' ./jazz-core/create-serverless-service/config/stg-config.json
sed -i 's/set BITBUCKETELB.*.$/set BITBUCKETELB=%bitbucketelb_dns_name%/g' ./bitbucketclient.cmd
