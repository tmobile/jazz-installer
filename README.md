# Jazz (Developer Preview) Installer - Overview

**Jazz Installer** - Installs [Jazz Serverless Developer Framework in AWS Cloud](https://github.com/tmobile/jazz-core/wiki).

**Note** : Please go through [limitations](#limitations) before you proceed.*
       Also Make sure [prerequisites](#prerequisites) are met before you proceed with the installation.
       Currently we are supporting the Linux based Installer and Windows based jazz installer is coming soon. 

# Prerequisites
* Create AWS account with permissions/privileges to create the 
  [AWS Resources](#aws-resources) (listed below) in us-east-1 region. 
* Use RHEL 7 instance as your installer box. More details please refer [here](https://github.com/tmobile/jazz-installer/wiki/Launch-AWS-RHEL7-Instance-for-Installer)


## Installation - (SSH to RHEL 7 instance and follow steps)
1) Run the below command to run the installation Wizard and provide prompted AWS configurations

```
    curl -L https://raw.githubusercontent.com/tmobile/jazz-installer/master/installscripts/terraforminstaller/rhel7Installer.sh?token=AcuYLfUy56QFj_7wyw-tWDapxZV-triUks5ZnYtmwA%3D%3D -o rhel7Installer.sh && chmod +x rhel7Installer.sh && ./rhel7Installer.sh && cd ./jazz-installer/installscripts/wizard && ./run.py
 
 ```

2) The installer supports the following installations. Please follow the installation wizard prompts.
     1. [Full Stack Installation](https://github.com/tmobile/jazz-installer/wiki/Jazz-Supported-Installations#full-stack-installation)- Creates Network and the rest of the stack.
     
     1. [Installation with existing network](https://github.com/tmobile/jazz-installer/wiki/Jazz-Supported-Installations#installation-with-existing-network) - Uses existing network to build the stack.
     
     1. [Installation with existing Jenkins and Bitbucket servers](https://github.com/tmobile/jazz-installer/wiki/Jazz-Supported-Installations#installation-with-existing-jenkins-and-bitbucket-servers) - Uses existing Jenkins and Bitbucket Servers (as provided) to build the stack.

    

# Limitations
* We are creating the stack on us-east-1 region. Because us-east-2 has permission issue with s3 Bucket and Cognito resource is not available in us-west-1 region.
* We have limitation of one stack on a region for an account. (coming soon - this limitation will be removed)

# AWS Resources 
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

# Wiki - For more details visit our wiki page
Please refer to the [wiki pages](https://github.com/tmobile/jazz-installer/wiki) for more details.

Please refer to [Getting Started with Service Development using Serverless](https://github.com/tmobile/jazz-core/wiki/Getting-Started-with-Service-Development-using-Serverless)

Please refer to [Jazz-Core Wiki](https://github.com/tmobile/jazz-core/wiki)
