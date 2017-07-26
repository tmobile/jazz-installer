set JENKINSELB=%1
set jenkinsattribsfile=%2
set bitbucketclientconfig=./bitbucketclient.cmd
REM removing as per vinays request on 07/12/2017- Its been taken care of another way
REM sed -i 's/"JOB_BUILD_URL.*.job/"JOB_BUILD_URL":"http:\/\/%JENKINSELB%:8080\/job/g' ./jazz-core/create-serverless-service/config/dev-config.json
REM sed -i 's/"JOB_BUILD_URL.*.job/"JOB_BUILD_URL":"http:\/\/%JENKINSELB%:8080\/job/g' ./jazz-core/create-serverless-service/config/prod-config.json
REM sed -i 's/"JOB_BUILD_URL.*.job/"JOB_BUILD_URL":"http:\/\/%JENKINSELB%:8080\/job/g' ./jazz-core/create-serverless-service/config/stg-config.json
sed -i "s/default\['jenkinselb'\].*.$/default['jenkinselb']='%JENKINSELB%'/g"  %jenkinsattribsfile%
sed -i 's/set JENKINSELB.*.$/set JENKINSELB=%JENKINSELB%/g'  %bitbucketclientconfig%

