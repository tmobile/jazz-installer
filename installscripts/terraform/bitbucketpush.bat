@ECHO OFF
set BITBUCKETELB=%1

git config --global user.email "harin.jose@ust-global.com"
git config --global user.name "jenkins1"
  
md jazz-core-bitbucket
cd jazz-core

FOR /F "tokens=*" %%G IN ('DIR /B /AD /S *.git') DO RMDIR /S /Q "%%G"

for /F "delims=" %%a in ('dir /ad /b') do (
      echo %%a  	  
	  
	  curl -X POST -k -v -u "jenkins1:jenkinsadmin" -H "Content-Type: application/json" "http://%BITBUCKETELB%:7990/rest/api/1.0/projects/SLF/repos" -d "{\"name\":\"%%a\", \"scmId\": \"git\", \"forkable\": \"true\"}"
	  
	  cd ../jazz-core-bitbucket
	  
	  git clone http://jenkins1:jenkinsadmin@%1:7990/scm/SLF/%%a.git
	  
	  echo %cd%/%%a
	  
	  echo %cd%/../jazz-core-bitbucket/%%a
	  
	  robocopy %cd%/%%a %cd%/../jazz-core-bitbucket/%%a /e
	  
	  cd %cd%/../jazz-core-bitbucket/%%a
	  
	  git add --all
      git commit -m "First Code commit"
      git remote -v
      git push -u origin master
	  
	  cd ../../jazz-core/

)
cd ../