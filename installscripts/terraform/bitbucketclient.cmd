rem set hookconfig="{\"hook-url-0\":\"http://demojenkins-elb-1605273568.us-east-2.elb.amazonaws.com:8080/bitbucket-hook/\"}"
set hookconfig="{\"hook-url-0\":\"http://%1:8080/bitbucket-hook/\"}"
set hookkey=com.atlassian.stash.plugin.stash-web-post-receive-hooks-plugin:postReceiveHook
set JENKINSELB=demo1jenkinselb-999027268.us-east-1.elb.amazonaws.com
set BITBUCKETELB=demo1bitbucketelb-1377218255.us-east-1.elb.amazonaws.com
set BASEURL=http://%BITBUCKETELB%:7990
rem set BASEURL=http://demobitbucketelb-1977064032.us-east-2.elb.amazonaws.com:7990
set USER=jenkins1
set PASS=jenkinsadmin
set CLIENTJAR=c:/project/software/atlassian-cli-6.7.1/lib/bitbucket-cli-6.7.0.jar
set OUTPUTFORMAT=2
set OUTPUTFILE=hookoutput.csv
set OUTPUTFILE=hookupdateoutput.csv
set OUTPUTFILE=createprojectoutput.csvset ACTION=getProject --project "CAS"
set ACTION=getProjectList --outputFormat %OUTPUTFORMAT% -f %OUTPUTFILE%
set ACTION=getHookList --project "CAS"  --repository "newService-201706200619 " --outputFormat %OUTPUTFORMAT% -f %OUTPUTFILE%
set ACTION=updatehook --project "CAS"  --repository "newService-201706200619 " --hook %hookkey% --config %hookconfig% 
set ACTION=createRepository --project "Test" --repository "testrepo" --name "testing-repo" --public --forkable


set ACTION=createProject --project "SLF"  --name "SLF" --description " created from cli" --public
java -jar %CLIENTJAR% -s %BASEURL% -u %USER% -p %PASS% --action %ACTION% 
set ACTION=createProject --project "CAS"  --name "CAS" --description " created from cli" --public
java -jar %CLIENTJAR% -s %BASEURL% -u %USER% -p %PASS% --action %ACTION% 

rem curl -X POST -k -v -u "jenkins1:jenkinsadmin" -H "Content-Type: application/json" "http://%BITBUCKETELB%:7990/rest/api/1.0/projects/" -d "{\"name\":\"SLF\", \"public\": \"true\"}"
rem curl -X POST -k -v -u "jenkins1:jenkinsadmin" -H "Content-Type: application/json" "http://%BITBUCKETELB%:7990/rest/api/1.0/projects/" -d "{\"name\":\"CAS\", \"public\": \"true\"}"


rem set ACTION=updatehook --project "CAS"  --repository "testrepo" --hook %hookkey% --config %hookconfig% 
rem java -jar %CLIENTJAR% -s %BASEURL% -u %USER% -p %PASS% --action %ACTION% 
call bitbucketpush.bat %BITBUCKETELB%
call curl  http://%JENKINSELB%:8080/job/inst_deploy_createservice/build?token=triggerCreateService --user jenkinsadmin:jenkinsadmin