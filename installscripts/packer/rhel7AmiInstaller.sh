#!/bin/bash
#---git
sudo yum install -y git
#----java
curl -v -j -k -L -H "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.rpm > jdk-8u112-linux-x64.rpm
sudo rpm -ivh ./jdk-8u112-linux-x64.rpm
#-----------aws
sudo yum install -y unzip
sudo curl -L https://s3.amazonaws.com/aws-cli/awscli-bundle.zip -o /tmp/awscli-bundle.zip
cd /tmp; sudo unzip awscli-bundle.zip
sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws

#---------------------------------------
sudo curl -L https://releases.hashicorp.com/terraform/0.9.11/terraform_0.9.11_linux_amd64.zip?_ga=2.191030627.850923432.1499789921-755991382.1496973261 -o /tmp/terraform.zip
sudo curl -L https://releases.hashicorp.com/packer/1.0.2/packer_1.0.2_linux_amd64.zip?_ga=2.211418261.1015376711.1499791279-168406014.1496924698 -o /tmp/packer.zip
sudo curl -L https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 -o /usr/local/bin/jq; sudo chmod 755 /usr/local/bin/jq
cd /usr/bin; sudo unzip /tmp/terraform.zip; sudo unzip /tmp/packer.zip
cd /home/ec2-user; sudo curl -L https://bobswift.atlassian.net/wiki/download/attachments/16285777/atlassian-cli-6.7.1-distribution.zip -o /tmp/atlassian-cli-6.7.1-distribution.zip; sudo unzip /tmp/atlassian-cli-6.7.1-distribution.zip

git clone -b patch-6 https://github.com/tmobile/jazz-installer.git
chmod -R +x ./jazz-installer/installscripts/*
chmod 400 ./jazz-installer/installscripts/sshkeys/*
