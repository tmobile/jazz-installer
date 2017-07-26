set securityGroupIds=%1
set subnetIds=%2
set iamRoleARN=%3
set region=%4
sed -i 's/securityGroupIds.*.$/securityGroupIds: %securityGroupIds%/g' ./jazz-core/api-template-java/deployment-env.yml
sed -i 's/subnetIds.*.$/subnetIds: %subnetIds%/g' ./jazz-core/api-template-java/deployment-env.yml
sed -i 's=iamRoleARN.*.$=iamRoleARN: %iamRoleARN%=g' ./jazz-core/api-template-java/deployment-env.yml
sed -i 's/region.*.$/region: %region%/g' ./jazz-core/api-template-java/deployment-env.yml

sed -i 's/securityGroupIds.*.$/securityGroupIds: %securityGroupIds%/g' ./jazz-core/api-template-nodejs/deployment-env.yml
sed -i 's/subnetIds.*.$/subnetIds: %subnetIds%/g' ./jazz-core/api-template-nodejs/deployment-env.yml
sed -i 's=iamRoleARN.*.$=iamRoleARN: %iamRoleARN%=g' ./jazz-core/api-template-nodejs/deployment-env.yml
sed -i 's/region.*.$/region: %region%/g' ./jazz-core/api-template-nodejs/deployment-env.yml



sed -i 's/securityGroupIds.*.$/securityGroupIds: %securityGroupIds%/g' ./jazz-core/create-serverless-service/deployment-env.yml
sed -i 's/subnetIds.*.$/subnetIds: %subnetIds%/g' ./jazz-core/create-serverless-service/deployment-env.yml
sed -i 's=iamRoleARN.*.$=iamRoleARN: %iamRoleARN%=g' ./jazz-core/create-serverless-service/deployment-env.yml
sed -i 's/region.*.$/region: %region%/g' ./jazz-core/create-serverless-service/deployment-env.yml
