# Jazz Installer (Developer Preview)
## Overview

**Jazz Installer** - Installs [Jazz Serverless Developer Framework in AWS Cloud](https://github.com/tmobile/jazz-core/wiki).

**Note** : Please go through [limitations](#limitations) before you proceed.
       Also Make sure [prerequisites](#prerequisites) are met before you proceed with the installation.
       Currently we are supporting the Linux based Installer and Windows based jazz installer is coming soon. 

## Prerequisites
* Create AWS account with permissions/privileges to create the 
  [AWS Resources](https://github.com/tmobile/jazz-installer/wiki/Jazz-Supported-Installations#aws-resources) (as listed) in us-east-1 region. 
* Use RHEL 7 instance as your installer box. [How to Launch AWS RHEL7 Instance](https://github.com/tmobile/jazz-installer/wiki/Launch-AWS-RHEL7-Instance-for-Installer)


## Installation steps
1) SSH to RHEL 7 instance
2) Run the below command to run the installation Wizard and provide prompted AWS configurations

```
curl -L https://raw.githubusercontent.com/tmobile/jazz-installer/master/installscripts/terraforminstaller/rhel7Installer.sh?token=AcuYLfUy56QFj_7wyw-tWDapxZV-triUks5ZnYtmwA%3D%3D -o rhel7Installer.sh && chmod +x rhel7Installer.sh && ./rhel7Installer.sh && cd ./jazz-installer/installscripts/wizard && ./run.py 
 ```

3) Follow the Installer Wizard prompts to Install the Framework, starting by providing the AWS Configurations.

   3.1) Provide the Stack-Prefix-Name in the Installer Wizard prompt

        Please provide the tag Name to Prefix your Stack(Eg:- jazz10 ): jazz123
        
     **Please use only lowercase alphabets & numbers for tag Name. Some of the artifacts are named using this and AWS has restrictions on the name. Please check AWS console if there are artifacts created with this name. If yes please choose another name**

   3.2) Do you want Full Stack Installation including network & Servers(Jenkins, BitBucket) creation

        Do you need full stack including network(Y/N): Y

     * If Y
      
       then the installer will go for [Full Stack Installation](https://github.com/tmobile/jazz-installer/wiki/Jazz-Supported-Installations#full-stack-installation)- Creates Network and the rest of the stack. 
      
       No futher steps are needed and the Installer Wizard will trigger the Installation of the Framework.
      
       Keep updated on [Installation status](https://github.com/tmobile/jazz-installer/wiki/Jazz-Supported-Installations#installation---status).

    * If N
      
      then follow the further Wizard prompts to install the Framework with existing network. (Follow step 3.3).

    3.2.1) Do you want to make use existing Jenkins and Bitbucket Server [Final Step]

        Do you have existing Jenkins and Bitbucket Server(Y/N): N

     * If N
      
       then the installer will go for [Installation with existing Network](https://github.com/tmobile/jazz-installer/wiki/Jazz-Supported-Installations#installation-with-existing-network). Please follow link Wizard prompts to complete the installation.

    * If Y
      
      then the installer will go for [Installation with existing Jenkins and Bitbucket servers](https://github.com/tmobile/jazz-installer/wiki/Jazz-Supported-Installations#installation-with-existing-jenkins-and-bitbucket-servers) - Uses existing Jenkins and Bitbucket Servers (as provided) to build the stack.  Please follow link Wizard prompts to complete the installation.

       Keep updated on [Installation status](https://github.com/tmobile/jazz-installer/wiki/Jazz-Supported-Installations#installation---status).

## Post Installation - Start using Jazz Framework - Create Developer API services
Jazz Framework provides Jazz-UI to create the Developer API Services and also displays the Services Catalog to manage the API services.

Post successful Installation, the Framework is ready to use and the start with using the [Jazz UI](https://github.com/tmobile/jazz-core/wiki/Jazz-UI---Overview) to create Developer API Services and refer [Getting Started with Service Development using Serverless](https://github.com/tmobile/jazz-core/wiki/Getting-Started-with-Service-Development-using-Serverless).

## Limitations
* Jazz stack will be created in us-east-1 region (we see few permission issues (s3 & cognito) when we use us-east-2 region)
* Only one stack can be created in one region per account (this limitation will be removed in the next version)

## Wiki
* [Installer](https://github.com/tmobile/jazz-installer/wiki)
* [Jazz UI](https://github.com/tmobile/jazz-core/wiki/Jazz-UI---Overview)
* [Jazz-Core](https://github.com/tmobile/jazz-core/wiki)
* [Getting Started with Service Development using Serverless](https://github.com/tmobile/jazz-core/wiki/Getting-Started-with-Service-Development-using-Serverless)
