# Jazz Installer (Developer Preview)
## Overview

**Jazz Installer** - Installs [Jazz Serverless Developer Framework in AWS Cloud](https://github.com/tmobile/jazz-core/wiki).

**Note**: Please go through [limitations](#limitations) before you proceed.
       Also, make sure that the [prerequisites](#prerequisites) are met before you proceed with the installation.
       Currently we are only supporting Linux based Installer (Windows based jazz installer is coming soon).

## Prerequisites
* AWS account is required. Ensure that you have the IAM keys with sufficient permissions to create the
  [AWS Resources](https://github.com/tmobile/jazz-installer/wiki/Jazz-Supported-Installations#aws-resources) in us-east-1 region.
* Use RHEL 7 instance as your installer machine [How to Launch AWS RHEL7 Instance](https://github.com/tmobile/jazz-installer/wiki/Launch-AWS-RHEL7-Instance-for-Installer).
* Make sure that the BitBucket server has below addons installed.
  * Atlassian Universal Plugin Manager Plugin
  * bitbucket-webhooks
  * Bob Swift Atlassian Add-ons - Bitbucket CLI Connector
  * Bitbucket Web Post Hooks Plugin
* Make sure that jenkins is installed as a service and JAVA_HOME is set to the path of JDK.
* Please make sure that provided jenkins & bitbucket user have admin rights.
* Login to the installer box; create jenkinskey.pem and bitbucketkey.pem with private keys of Jenkins and Bitbucket in /home/ec2-user
* Make sure that you have **Jenkins and Bitbucket** services available for integration with Jazz. Current version of Jazz integrates with publicly accessible Jenkins & Bitbucket services.
  * Note: Please note that some of the AWS resources are accessed through Jenkins during some of the internal orchestration activities.


## Installation steps
1) SSH to the installer machine (RHEL 7 instance as mentioned in the prerequisites).
2) Run the below command to run the installation wizard.

```
curl -L https://raw.githubusercontent.com/tmobile/jazz-installer/v1.1/installscripts/terraforminstaller/rhel7Installer.sh -o rhel7Installer.sh && chmod +x rhel7Installer.sh && ./rhel7Installer.sh v1.1 && cd ./jazz-installer/installscripts/wizard && ./run.py 
 ```

3) Follow the installer wizard. It prompts for few AWS configurations which needs to be filled in.

   3.1) Provide the prefix for your stack (**Please use only lowercase alphabets & numbers for tag name. Some of the artifacts are named using this informatin and AWS has restrictions on how we use this tag. Please check AWS console if there are artifacts created with this name. If yes, please choose another name!**)

        Please provide the tag Name to Prefix your Stack(Eg:- jazz10 ): myjazz

Installer will follow the steps specified in [Installation with existing Jenkins and Bitbucket servers](https://github.com/tmobile/jazz-installer/wiki/Jazz-Supported-Installations#installation-with-existing-jenkins-and-bitbucket-servers) - Uses existing Jenkins and Bitbucket Servers (as provided) to build the stack. Please ensure that you provide these details correctly during this process. Not doing so would result in installation failure. Please follow the wizard prompts to complete the installation.

Check the status through [Installation status](https://github.com/tmobile/jazz-installer/wiki/Jazz-Supported-Installations#installation---status).

## Post Installation - Start using Jazz to create your first service!
Jazz provides management UI to create and manage serverless services.

Post successful installation, start using [Jazz UI](https://github.com/tmobile/jazz-core/wiki/Jazz-UI---Overview) to create your services! Please refer to [Getting Started with Service Development using Serverless](https://github.com/tmobile/jazz-core/wiki/Getting-Started-with-Service-Development-using-Serverless).


## Limitations
* In this version, Jazz platform components will be created in us-east-1 region (we've seen few restrictions when using us-east-2 region).
* Only one stack can be created in one region per account (this limitation will be removed soon).

## Cleanup - Removing Jazz components from your AWS Account
Jazz installer contains the scripts to cleanup Jazz framework & remove all its components from your AWS account.

To clean up Jazz components, please refer to [Jazz Framework - Cleanup](https://github.com/tmobile/jazz-installer/wiki/Cleanup:-Jazz-Framework)

## Wiki
* [Jazz Framework](https://github.com/tmobile/jazz-core/wiki)
* [Getting Started with Service Development using Serverless](https://github.com/tmobile/jazz-core/wiki/Getting-Started-with-Service-Development-using-Serverless)
* [Installer](https://github.com/tmobile/jazz-installer/wiki)
