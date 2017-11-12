#!/bin/bash
date

stack_name=""
currentDir=`pwd`

echo " ======================================================="
echo " The following Stack has been marked for deletion in AWS"
echo " ________________________________________________"
cd installscripts/terraform-unix-noinstances-jazz
terraform state list

echo " ======================================================="

echo " Destroying of stack Initiated!!! "
echo " Execute  'tail -f stack_deletion.out' in below directory to see the stack deletion progress"
echo $currentDir

echo " ======================================================="

nohup terraform destroy --force >>../../stack_deletion.out &&
cd $currentDir
shopt -s extglob

# Calling the Delete platform services py script
/usr/bin/python scripts/DeleteStackPlatformServices.py $stack_name

sudo rm -rf !(*.out)
sudo rm -rf ../rhel7Installer.sh ../atlassian-cli*
date
