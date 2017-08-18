# Jazz Installer (Developer Preview)
## Overview

**Jazz Installer** - Installs [Jazz Serverless Developer Framework in AWS Cloud](https://github.com/tmobile/jazz-core/wiki).

**Note** : Please go through [limitations](#limitations) before you proceed.
       Also Make sure [prerequisites](#prerequisites) are met before you proceed with the installation.
       Currently we are supporting the Linux based Installer and Windows based jazz installer is coming soon. 

## Prerequisites
* Create AWS account with permissions/privileges to create the 
  [AWS Resources](#aws-resources) (listed below) in us-east-1 region. 
* Use RHEL 7 instance as your installer box. [How to Launch AWS RHEL7 Instance](https://github.com/tmobile/jazz-installer/wiki/Launch-AWS-RHEL7-Instance-for-Installer)


## Installation steps
1) SSH to RHEL 7 instance
2) Run the below command to run the installation Wizard and provide prompted AWS configurations

```
curl -L https://raw.githubusercontent.com/tmobile/jazz-installer/master/installscripts/terraforminstaller/rhel7Installer.sh?token=AcuYLfUy56QFj_7wyw-tWDapxZV-triUks5ZnYtmwA%3D%3D -o rhel7Installer.sh && chmod +x rhel7Installer.sh && ./rhel7Installer.sh && cd ./jazz-installer/installscripts/wizard && ./run.py 
 ```

3) The installer supports the following installations. Please follow the installation wizard prompts. (The installer will take around 20-30mins (for a AWS RHEL T2.micro instance) to complete.)

     1. [Full Stack Installation](https://github.com/tmobile/jazz-installer/wiki/Jazz-Supported-Installations#full-stack-installation)- Creates Network and the rest of the stack.   
     1. [Installation with existing network](https://github.com/tmobile/jazz-installer/wiki/Jazz-Supported-Installations#installation-with-existing-network) - Uses existing network to build the stack.     
     1. [Installation with existing Jenkins and Bitbucket servers](https://github.com/tmobile/jazz-installer/wiki/Jazz-Supported-Installations#installation-with-existing-jenkins-and-bitbucket-servers) - Uses existing Jenkins and Bitbucket Servers (as provided) to build the stack.


  4) Installation - status
  
     Note: the nohop.out will be in ~/jazz-installer/installscripts/terraform-unix-demo-jazz or for Installation with existing servers in ~/jazz-installer/installscripts/terraform-unix-noinstances-jazz

     A. The installer will take around 20-30mins (for a AWS RHEL T2.micro instance) to complete.
     
       a. To ensure Installation completion, please execute the below statement

              tail -f nohup.out | grep 'Installation Completed!!!'

       b. On Installation completion you would - you should be able to see the below text:
  
          **Installation Completed!!!**

       c. Then run below statement: to get the Jazz Stack details (Jenkins, Bitbucket, Jazz Web Application URLs)

            cat settings.txt
       
    B. If the installation does not complete in 40 mins or so, please review the nohop.out for any error messages.

## Limitations
* We are creating the stack on us-east-1 region. Because us-east-2 has permission issue with s3 Bucket and Cognito resource is not available in us-west-1 region.
* We have limitation of one stack on a region for an account. (coming soon - this limitation will be removed)

## AWS Resources 
    AWS AMIs
    AWS::ApiGateway
    AWS::CloudFront
    AWS::Cognito
    AWS::DynamoDB
    AWS::IAM::Policy
    AWS::EC2::Instance
    AWS::ElasticLoadBalancing::LoadBalancer
    AWS::Lambda
    AWS::S3::Bucket
    AWS::Elasticsearch::Domain

## Wiki
* [Installer](https://github.com/tmobile/jazz-installer/wiki)
* [Jazz-Core](https://github.com/tmobile/jazz-core/wiki)
* [Getting Started with Service Development using Serverless](https://github.com/tmobile/jazz-core/wiki/Getting-Started-with-Service-Development-using-Serverless)
