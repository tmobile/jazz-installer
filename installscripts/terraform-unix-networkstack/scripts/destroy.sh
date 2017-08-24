#!/bin/bash
date

currentDir=`pwd`

echo " ======================================================="
echo " The following Stack has been marked for deletion in AWS"
echo " ________________________________________________"
cd ../terraform-unix-demo-jazz
terraform state list

cd ../terraform-unix-networkstack
terraform state list
echo " ======================================================="

cd ../terraform-unix-demo-jazz

terraform destroy --force &&

cd ../terraform-unix-networkstack

terraform destroy --force


echo " Destroying of stack Initiated!!! "
echo " Execute  tail -f nohup.out ' in below directory to see the stack deletion progress"
echo $currentDir
echo " ======================================================="