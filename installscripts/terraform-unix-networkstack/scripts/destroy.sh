#!/bin/bash
date
cidr=CIDRPLACEHOLDER
currentDir=`pwd`

echo " ======================================================="
echo " The following Stack has been marked for deletion in AWS"
echo " ________________________________________________"
cd installscripts/terraform-unix-demo-jazz
terraform state list

cd ../terraform-unix-networkstack
terraform state list
echo " ======================================================="

echo " Destroying of stack Initiated!!! "
echo " Execute  'tail -f stack_deletion.out' and 'tail -f network_stack_deletion.out' in below directory to see the stack deletion progress"
echo $currentDir
echo " ======================================================="

cd ../terraform-unix-demo-jazz

nohup terraform destroy --force >>../../stack_deletion.out &&

cd ../terraform-unix-networkstack

nohup terraform destroy -var "cidrblocks=$cidr" --force >>../../network_stack_deletion.out &&

cd $currentDir
shopt -s extglob
sudo rm -rf !(*.out)
sudo rm -rf ../rhel7Installer.sh ../atlassian-cli* 

date
