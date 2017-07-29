rem call :removeAMI
call :createimage
goto:eof

:removeAMI
	REM jenkins server
	rem call aws ec2 deregister-image --image-id ami-7abe981f
	REM jenkins slave
	call aws ec2 deregister-image --image-id ami-09bd9b6c
	REM bitbucket
	rem call aws ec2 deregister-image --image-id ami-e0bd9b85
	REM base box
	rem call aws ec2 deregister-image --image-id ami-95b197f0
goto:eof
:createimage
	call aws ec2 create-image --instance-id i-02952b5ce8429a4f7 --name "bitbucket server" --description "as of 03/22/2017" --no-reboot
	call aws ec2 create-image --instance-id i-092ced5a39cfc9495 --name "jenkins slave" --description "as of 03/22/2017" --no-reboot
	call aws ec2 create-image --instance-id i-0f6c62d80acee1f0f --name "jenkins server" --description "as of 03/22/2017" --no-reboot
goto:eof
