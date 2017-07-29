@ECHO OFF
set BUCKET_NAME=%1
set PROJECT_FOLDER=%2
cd %PROJECT_FOLDER%

FOR /F "tokens=*" %%G IN ('DIR /B /AD /S *.git') DO RMDIR /S /Q "%%G"

for /F  %%a in ('dir /S /B ^| sed -e "s/^.*.app\\\//g" -e "s=\\\=/=g" ') do (
     echo %%a  
	 aws s3api put-object-acl --bucket %BUCKET_NAME% --key %%a --grant-full-control id=78d7d8174c655d51683784593fe4e6f74a7ed3fae3127d2beca2ad39e4fdc79a,uri=http://acs.amazonaws.com/groups/s3/LogDelivery,uri=http://acs.amazonaws.com/groups/global/AuthenticatedUsers --grant-read uri=http://acs.amazonaws.com/groups/global/AllUsers   --grant-read-acp uri=http://acs.amazonaws.com/groups/global/AllUsers 
)
cd ..\..\..\