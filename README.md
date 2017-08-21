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
Follow the Installer Wizard prompts to Install the Framework, starting by providing the AWS Configurations.

3) Provide the Stack-Prefix-Name in the Installer Wizard prompt

        Please provide the tag Name to Prefix your Stack(Eg:- jazz10 ): jazz123
        
   **Please use only lowercase alphabets & numbers for tag Name. Some of the artifacts are named using this and AWS has restrictions on the name. Please check AWS console if there are artifacts created with this name. If yes please choose another name**

4) Provide Full Stack Installation - option (Y)

        Do you need full stack including network(Y/N): Y

   If Y - is the option then **The Installer Wizard will trigger the Installation of the Framework.**
     a. For more information on [Full Stack Installation](https://github.com/tmobile/jazz-installer/wiki/Jazz-Supported-Installations#full-stack-installation)- Creates Network and the rest of the stack.
     b. **Please refer [Installation Status](#installation---status) section to know the Installation status.**

5) Provide Full Stack Installation - option (N)

        Do you need full stack including network(Y/N): N

   Follow the further Wizard prompts to install the Framework with existing stack.

6) Provide use existing Jenkins and Bitbucket Server option = N

        Do you have existing Jenkins and Bitbucket Server(Y/N): N
 
      If N - is the option then

      a. Please refer [Installation with existing network](https://github.com/tmobile/jazz-installer/wiki/Jazz-Supported-Installations#installation-with-existing-network) - Uses existing network to build the stack.
      b. And provide more Wizard options.
      
          Do you have existing Jenkins and Bitbucket Server(Y/N): n
          We will create Jenkins and Bitbucket Servers using the Network Stack you provided
          Please have vpc,subnet and cidr blocks handy
          Please provide VPC id: vpc-e1b9b784
          Please provide subnet id: subnet-c5caafee
          Please provide CIDR BLOCK: 172.31.0.0/16
      
      **With the above details - the Installer Wizard will trigger the Installation of the Framework.**
      
      c. Please refer [Installation Status](#installation---status) section to know the Installation status.
 
7) Provide use existing Jenkins and Bitbucket Server option = Y

        Do you have existing Jenkins and Bitbucket Server(Y/N): Y
 
      If N - is the option then

      1. Please refer [Installation with existing Jenkins and Bitbucket servers](https://github.com/tmobile/jazz-installer/wiki/Jazz-Supported-Installations#installation-with-existing-jenkins-and-bitbucket-servers) - Uses existing Jenkins and Bitbucket Servers (as provided) to build the stack. And provide more Wizard options.
      1. Please refer [Installation Status](#installation---status) section to know the Installation status.
 

## Installation - status
  
  Note: the nohop.out will be in ~/jazz-installer/installscripts/terraform-unix-demo-jazz or for Installation with existing servers in ~/jazz-installer/installscripts/terraform-unix-noinstances-jazz

     A. The installer will take around 20-30mins (for a AWS RHEL T2.micro instance) to complete.
     
       a. To ensure Installation completion, please execute the below statement

              tail -f nohup.out | grep 'Installation Completed!!!'

       b. On Installation completion - you should be able to see the below text as response to above command:
  
              Installation Completed!!!

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
