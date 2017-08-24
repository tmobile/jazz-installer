#!/bin/bash
date

currentDir=`pwd`

echo " ======================================================="
echo " The following Stack has been marked for deletion in AWS"
echo " ________________________________________________"
cd ../terraform-unix-demo-jazz
terraform state list

echo " ======================================================="

terraform destroy --force


echo " Destroying of stack Initiated!!! "
echo " Execute  tail -f nohup.out ' in below directory to see the stack deletion progress"
echo $currentDir
echo " ======================================================="

