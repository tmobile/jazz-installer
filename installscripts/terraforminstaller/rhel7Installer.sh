#!/bin/bash
export PS1='$PWD:>'
logfilename=installer_setup.log
logfile=`realpath $logfilename`
spin_wheel()
{
RED='\033[0;31m'
NC='\033[0m'
setterm -term linux -fore green
pid=$1 # Process Id of the previous running command
message=$2
spin='-\|/'
printf "\r$message...."
i=0
#while kill -0 $pid 2>/dev/null
while ps -p $pid > /dev/null
do
  #echo $pid $i
  i=$(( (i+1) %4 ))
  printf "\r$message....${spin:$i:1}"
  sleep .05
done
#setterm -term linux -fore default

wait "$pid"
exitcode=$?
if [ $exitcode -gt 0 ]
then
    printf "\r${RED}$message....Failed${NC}\n"
    exit
else
    printf "\r$message....Completed\n"

fi
}


#---git
sudo yum install -y git >>$logfile&
spin_wheel $! "Installing git"

#----java
curl -v -j -k -L -H "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.rpm -o jdk-8u112-linux-x64.rpm >>$logfile 2>&1&
spin_wheel $! "Downloading java"

sudo rpm -ivh --force ./jdk-8u112-linux-x64.rpm >>$logfile 2>&1&
spin_wheel $! "Installing java"

sudo rm -rf jdk-8u112-linux-x64.rpm

#----unzip
sudo yum install -y unzip >>$logfile 2>&1&
spin_wheel $! "Installing unzip"

#----awscli
sudo curl -L https://s3.amazonaws.com/aws-cli/awscli-bundle.zip -o /tmp/awscli-bundle.zip >> $logfile 2>&1 &
spin_wheel $! "Downloading  awscli bundle"
cd /tmp; sudo rm -rf awscli-bundle; sudo unzip awscli-bundle.zip >>$logfile 2>&1 &
spin_wheel $! "Unzipping  awscli bundle"
sudo rm -rf /usr/local/aws
sudo rm -f /usr/local/bin/aws

sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws >>$logfile 2>&1 &
spin_wheel $! "Installing  awscli bundle"

#--terraform
sudo curl -v -L https://releases.hashicorp.com/terraform/0.9.11/terraform_0.9.11_linux_amd64.zip?_ga=2.191030627.850923432.1499789921-755991382.1496973261 -o /tmp/terraform.zip >>$logfile 2>&1 &
spin_wheel $! "Downloading terraform"
cd /usr/bin
sudo unzip -o /tmp/terraform.zip >>$logfile 2>&1 &
spin_wheel $! "Installing terraform"

#--packer
sudo curl -L https://releases.hashicorp.com/packer/1.0.2/packer_1.0.2_linux_amd64.zip?_ga=2.211418261.1015376711.1499791279-168406014.1496924698 -o /tmp/packer.zip >>$logfile 2>&1 &
spin_wheel $! "Downloading packer"
sudo unzip -o /tmp/packer.zip>>$logfile 2>&1 &
spin_wheel $! "Installing packer"

#--jq
sudo curl -L https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 -o /usr/local/bin/jq >>$logfile 2>&1 &
spin_wheel $! "Installing jq"
sudo chmod 755 /usr/local/bin/jq

#--atlassian
cd /home/ec2-user; sudo curl -L https://bobswift.atlassian.net/wiki/download/attachments/16285777/atlassian-cli-6.7.1-distribution.zip -o /tmp/atlassian-cli-6.7.1-distribution.zip >>$logfile 2>&1 &
spin_wheel $! "Downloading atlassian-cli"
sudo unzip -o /tmp/atlassian-cli-6.7.1-distribution.zip  >>$logfile 2>&1 &
spin_wheel $! "Installing atlassian-cli"

#--cloning from github
sudo rm -rf jazz-installer
git clone -b development https://ustharin:Tmobiledemo1@github.com/tmobile/jazz-installer.git >>$logfile 2>&1 &
spin_wheel $! "Downloading jazz Installer"

chmod -R +x ./jazz-installer/installscripts/*
chmod -R 400 ./jazz-installer/installscripts/sshkeys/*
cd /home/ec2-user/jazz-installer/installscripts/wizard


setterm -term linux -fore default

read -p 'AWS Access Key ID :' access_key
read -p 'AWS Secret Access Key :' secret_key
aws_credentials="[default]
aws_access_key_id = $access_key
aws_secret_access_key = $secret_key"
aws_config="[default]
output = json
region = us-east-1"
mkdir -p ~/.aws
echo "$aws_credentials">~/.aws/credentials
echo "$aws_config">~/.aws/config

setterm -term linux -fore green
setterm -term linux -fore default
