#!/bin/bash
#
# File: Installer.sh
# Description: Installs the Jazz serverless framework from Centos7 ec2-instance.
#
# ---------------------------------------------
# Usage:
# ---------------------------------------------
# To Installer, run:
# ./Installer branch_name
# ---------------------------------------------

# Installation directory
INSTALL_DIR=`pwd`
REPO_PATH=$INSTALL_DIR/jazz-installer

# Log file to record the installation logs
LOG_FILE_NAME=installer_setup.out
LOG_FILE=`realpath $INSTALL_DIR/$LOG_FILE_NAME`

#Check if the Branch name is supplied
if [ $# -eq 0 ]
  then
	echo 'No arguments supplied for Installer'
  echo "Please re-run './Installer.sh branch_name' "
	exit
fi

JAZZ_BRANCH=$1

#Spin wheel
spin_wheel()
{
	RED='\033[0;31m'
	GREEN='\033[0;32m'
	NC='\033[0m'

	pid=$1 # Process Id of the previous running command
	message=$2
	spin='-\|/'
	printf "\r$message...."
	i=0

	while ps -p $pid > /dev/null
	do
	  #echo $pid $i
	  i=$(( (i+1) %4 ))
	  printf "\r${GREEN}$message....${spin:$i:1}"
	  sleep .05
	done

	wait "$pid"
	exitcode=$?
	if [ $exitcode -gt 0 ]
	then
		printf "\r${RED}$message....Failed${NC}\n"
		exit
	else
		printf "\r${GREEN}$message....Completed${NC}\n"

	fi
}

trap 'printf "${RED}\nCancelled....\n${NC}"; exit' 2
trap '' 20

# Download and Installing Softwares required for Jazz Installer
# 1. GIT
# 2. Java Jdk - 8u112-linux-x64
# 3. Unzip
# 4. AWSCLI
# 5. Terraform - 0.9.11
# 6. JQ - 1.5
# 7. Atlassian CLI - 6.7.1

# Install git
sudo yum install -y git >>$LOG_FILE&
spin_wheel $! "Installing git"

# Download and Install java
curl -v -j -k -L -H "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.rpm -o jdk-8u112-linux-x64.rpm >>$LOG_FILE 2>&1&
spin_wheel $! "Downloading java"

sudo rpm -ivh --force ./jdk-8u112-linux-x64.rpm >>$LOG_FILE 2>&1&
spin_wheel $! "Installing java"

sudo rm -rf jdk-8u112-linux-x64.rpm

# Download and Install unzip
sudo yum install -y unzip >>$LOG_FILE 2>&1&
spin_wheel $! "Installing unzip"

# Create a temporary folder .
# Here we will have all the temporary files needed and delete it at the end
sudo rm -rf $INSTALL_DIR/jazz_tmp
mkdir $INSTALL_DIR/jazz_tmp

# Download and Install awscli
sudo curl -L https://s3.amazonaws.com/aws-cli/awscli-bundle.zip -o $INSTALL_DIR/jazz_tmp/awscli-bundle.zip >> $LOG_FILE 2>&1 &
spin_wheel $! "Downloading  awscli bundle"
sudo rm -rf $INSTALL_DIR/jazz_tmp/awscli-bundle
sudo unzip $INSTALL_DIR/jazz_tmp/awscli-bundle.zip -d $INSTALL_DIR/jazz_tmp>>$LOG_FILE 2>&1 &
spin_wheel $! "Unzipping  awscli bundle"
sudo rm -rf /usr/local/aws
sudo rm -f /usr/local/bin/aws

cd $INSTALL_DIR/jazz_tmp/awscli-bundle/
sudo ./install -i /usr/local/aws -b /usr/local/bin/aws >>$LOG_FILE 2>&1 &
spin_wheel $! "Installing  awscli bundle"
cd $INSTALL_DIR/

#Download and Install Terraform
sudo curl -v -L https://releases.hashicorp.com/terraform/0.9.11/terraform_0.9.11_linux_amd64.zip?_ga=2.191030627.850923432.1499789921-755991382.1496973261 -o $INSTALL_DIR/jazz_tmp/terraform.zip >>$LOG_FILE 2>&1 &
spin_wheel $! "Downloading terraform"
sudo unzip -o $INSTALL_DIR/jazz_tmp/terraform.zip -d /usr/bin>>$LOG_FILE 2>&1 &
spin_wheel $! "Installing terraform"

#Downloading and Install atlassian-cli
sudo curl -L https://bobswift.atlassian.net/wiki/download/attachments/16285777/atlassian-cli-6.7.1-distribution.zip -o $INSTALL_DIR/jazz_tmp/atlassian-cli-6.7.1-distribution.zip >>$LOG_FILE 2>&1 &
spin_wheel $! "Downloading atlassian-cli"
sudo unzip -o ~/jazz_tmp/atlassian-cli-6.7.1-distribution.zip  >>$LOG_FILE 2>&1 &
spin_wheel $! "Installing atlassian-cli"

#Get Jazz Installer code base
sudo rm -rf jazz-installer
git clone -b $JAZZ_BRANCH https://github.com/tmobile/jazz-installer.git >>$LOG_FILE 2>&1 &
spin_wheel $! "Downloading jazz Installer"

#Download and Install wget
sudo yum install -y wget >>$LOG_FILE 2>&1 &
spin_wheel $! "Downloading and install wget"

#Download and install pip
sudo wget -q https://bootstrap.pypa.io/get-pip.py
sudo python get-pip.py >>$LOG_FILE 2>&1 &
spin_wheel $! "Downloading and install pip"

#Download and install paramiko
sudo pip install paramiko >>$LOG_FILE 2>&1 &
spin_wheel $! "Downloading and install paramiko"

#move the software install log jazz Installer
mv $LOG_FILE $REPO_PATH

#set the permissions
chmod -R +x $REPO_PATH/installscripts/*
mkdir -p $REPO_PATH/installscripts/sshkeys/dockerkeys

#Call the python script to continue installation process
cd $REPO_PATH/installscripts/wizard
sed -i "s|\"jazz_install_dir\".*$|\"jazz_install_dir\": \"$INSTALL_DIR\"|g" config.py
python ./run.py $JAZZ_BRANCH $INSTALL_DIR

#Clean up the jazz_tmp folder
sudo rm -rf $INSTALL_DIR/jazz_tmp

setterm -term linux -fore green
setterm -term linux -fore default
