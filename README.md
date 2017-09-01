# Jazz Installer (Developer Preview)
## Overview

**Jazz Installer** - Installs [Jazz Serverless Developer Framework in AWS Cloud](https://github.com/tmobile/jazz-core/wiki).

**Note**: Please go through [limitations](#limitations) before you proceed.
       Also, make sure that the [prerequisites](#prerequisites) are met before you proceed with the installation.
       Currently we are only supporting Linux based Installer (Windows based jazz installer is coming soon). 

## Prerequisites
* AWS account is required. Ensure that you have the IAM keys with sufficient permissions to create the 
  [AWS Resources](https://github.com/tmobile/jazz-installer/wiki/Jazz-Supported-Installations#aws-resources) in us-east-1 region. 
* Use RHEL 7 instance as your installer machine [How to Launch AWS RHEL7 Instance](https://github.com/tmobile/jazz-installer/wiki/Launch-AWS-RHEL7-Instance-for-Installer)


## Installation steps
1) SSH to the installer machine (RHEL 7 instance as mentioned in the Prerequisites).
2) Run the below command to run the installation wizard.

```
curl -L https://raw.githubusercontent.com/tmobile/jazz-installer/master/installscripts/terraforminstaller/rhel7Installer.sh?token=AcuYLXYT95V5yMTthc44KmsMfayGbOxSks5Zso1_wA%3D%3D -o rhel7Installer.sh && chmod +x rhel7Installer.sh && ./rhel7Installer.sh && cd ./jazz-installer/installscripts/wizard && ./run.py 
 ```

3) Follow the installer wizard. It prompts for few AWS configurations which needs to be filled in.

   3.1) Provide the prefix for your stack (**Please use only lowercase alphabets & numbers for tag name. Some of the artifacts are named using this informatin and AWS has restrictions on how we use this tag. Please check AWS console if there are artifacts created with this name. If yes, please choose another name!**)

        Please provide the tag Name to Prefix your Stack(Eg:- jazz10 ): myjazz

   3.2) Do you need full stack installation including network & compute infrastructure (related to Jenkins & BitBucket)?

        Do you need full stack including network(Y/N): Y

        * If Y
      
              installer will create the network & compute infrastructure. No futher user action is needed! 
              Please refer to [Full Stack Installation](https://github.com/tmobile/jazz-installer/wiki/Jazz-Supported-Installations#full-stack-installation)
      
              
        * If N
      
              follow the next set of instructions to install the framework within an existing network.

              3.2.1) Do you want to make use of existing Jenkins and Bitbucket infrastructure?

                     Do you have existing Jenkins and Bitbucket Server(Y/N): N

                     * If N
        
                            installer will follow the steps specified in [Installation with existing Network](https://github.com/tmobile/jazz-installer/wiki/Jazz-Supported-Installations#installation-with-existing-network). Please follow link Wizard prompts to complete the installation.

                     * If Y
        
                            installer will follow the steps specified in [Installation with existing Jenkins and Bitbucket servers](https://github.com/tmobile/jazz-installer/wiki/Jazz-Supported-Installations#installation-with-existing-jenkins-and-bitbucket-servers) - Uses existing Jenkins and Bitbucket Servers (as provided) to build the stack.  Please follow link Wizard prompts to complete the installation.

Check the status through [Installation status](https://github.com/tmobile/jazz-installer/wiki/Jazz-Supported-Installations#installation---status).

## Post Installation - Start using Jazz Framework - Create your first service!
Jazz provides management UI to create and manage serverless services.

Post successful Installation, framework is ready to use! Start using [Jazz UI](https://github.com/tmobile/jazz-core/wiki/Jazz-UI---Overview) to create your services! Please refer to [Getting Started with Service Development using Serverless](https://github.com/tmobile/jazz-core/wiki/Getting-Started-with-Service-Development-using-Serverless).

## Limitations
* Jazz stack will be created in us-east-1 region (we see few permission issues (s3 & cognito) when we use us-east-2 region)
* Only one stack can be created in one region per account (this limitation will be removed in the next version)

## Wiki
* [Installer](https://github.com/tmobile/jazz-installer/wiki)
* [Jazz UI](https://github.com/tmobile/jazz-core/wiki/Jazz-UI---Overview)
* [Jazz-Core](https://github.com/tmobile/jazz-core/wiki)
* [Getting Started with Service Development using Serverless](https://github.com/tmobile/jazz-core/wiki/Getting-Started-with-Service-Development-using-Serverless)
