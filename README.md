# Jazz (Developer Preview) Installer - Overview

Jazz Installer - sets up the Jazz Serverless Developer Framework for API Services in AWS Cloud.
For more details on Jazz Serverless Development Framework, please refer [here](https://github.com/tmobile/jazz-core/wiki).

*Note: Please go through [limitations](#limitations) before you proceed.*
       Also Make sure prerequisites are met before you proceed with the installation.
       Currently we are supporting the Linux based Installer and Windows based jazz installer is coming soon. 

# Prerequisites
* Create AWS account with permissions/privileges to create the 
  [AWS Resources](#aws-resources) (listed below) in us-east-1 region. 
* Use RHEL 7 instance as your installer box. More details please refer [here](https://github.com/tmobile/jazz-installer/wiki/Launch-AWS-RHEL7-Instance-for-Installer)
* SSH to RHEL 7 instance and follow steps with 4 commands


## Installer - Steps
1) [Setup the RHEL 7 server with the Jazz installer](https://github.com/tmobile/jazz-installer/blob/patch-9/README.md#setup-the-rhel-7-server-with-the-jazz-installer)
2) [Provide Stack Prefix Name ](https://github.com/tmobile/jazz-installer/blob/patch-9/README.md#2-installer-prompt-1---stack-prefix-name-prompt)
3) Installer Wizard 3 options (opt for either of the three options)

     a) Full Stack Installation - [Installer Prompt - Full Stack installation = Y](https://github.com/tmobile/jazz-installer/blob/patch-9/README.md#3-installer-prompt---full-stack-installation--y)
     
     _With the above the Framework Installation is completed with new stack/network/servers._

     b) Existing Network reuse - [Installer Prompt - Full Stack installation = N](https://github.com/tmobile/jazz-installer/blob/patch-9/README.md#4-installer-prompt---full-stack-installation--n)
     
     _With the above the Framework Installation is completed with existing Network and newly jenkins/bitbucket servers._

     c) Existing Network/Servers reuse 
     
	      Flow below steps:
	  
	      i) Existing Network reuse -  [Installer Prompt - Full Stack installation = N](https://github.com/tmobile/jazz-installer/blob/patch-9/README.md#4-installer-prompt---full-stack-installation--n)
	 
	      ii) Existing Servers reuse - [Installer Prompt - xisting Jenkins and Bitbucket Server]()
     With the above the Framework Installation is completed with existing Network and existing jenkins/bitbucket servers.


# Setup the RHEL 7 server with the Jazz installer

Execute the below Command. The command to be executed inside RHEL 7 instance, which will install all required softwares in the RHEL server and will also clone the repository and continue setup the framework in the AWS Account.

### 1. Run below command
    curl -L https://raw.githubusercontent.com/tmobile/jazz-installer/master/installscripts/terraforminstaller/rhel7Installer.sh?token=AcuYLfUy56QFj_7wyw-tWDapxZV-triUks5ZnYtmwA%3D%3D -o rhel7Installer.sh && chmod +x rhel7Installer.sh && ./rhel7Installer.sh && cd ./jazz-installer/installscripts/wizard && ./run.py
  
This will prompt to enter AWS credentials (Access key, Secret key, Region and output format)

    AWS Access Key ID [None]:
    AWS Secret Access Key [None]:
    Default region name [None]:
    Default output format [None]: 
		
Example : 

    AWS Access Key ID = AKIAJ24MZSJQ7SYWXUNA
    AWS Secret Access Key = 2CZO1VgW4XdX/bg+tzHEc0E9NZY1J3omY6Uw/N+c
    Default region name= us-east-1
    Default output format=json

 ### 2. Installer Prompt 1 - Stack Prefix Name Prompt
  Follow the prompts to Install the Framework: 
  
     Please provide the tag Name to Prefix your Stack(Eg:- jazz10 ): jazz123
 
  (Please use only lowercase alphabets & numbers for tag Name. Some of the artifacts are named using this and AWS has restrictions on the name. Please check AWS console if there are artifacts created with this name. If yes please choose another name)
 

 ### 3. Installer Prompt - Full Stack installation = Y

 Follow the prompts to Install the Framework: 
 
     Do you need full stack including network(Y/N): Y
     
   If Y is the option then - [scenario 1](https://github.com/tmobile/jazz-installer/wiki/Jazz-Installation-scenarios#scenario-1---building-full-stack-network-instances-and-the-rest-of-the-stack) Installion flow is executed.

   **The installer would take some time to install the the framework and once completed settings.txt would contain the Framework's related URLs (Jenkins, BitBucket, Jazz Web Application).**


 Note: 
 * If the CIDR already exists, the script will exit with the following message and indicates further installer steps are to be followed
 
     **cidrcheck command =  aws ec2 describe-subnets --filters Name=cidrBlock,Values=10.0.0.0/16 --output=text > ./cidrexists
     default CIDR 10.0.0.0/16 already exists. Please try creating the stack again by providing own subnet**

   **Then run the below command to proceed with installation. Which is that the installer will follow the Option 2 flow:**
     ./run.py

 ### 4. Installer Prompt - Full Stack installation = N 
 
 Existing network Stack installation or Installer CIDR Already exists

 Building stack in an existing Network (provide Network information to create instances and the rest of the stack).
 
     
   If N is the option then - [scenario 2](https://github.com/tmobile/jazz-installer/wiki/Jazz-Installation-scenarios#scenario-2---building-stack-in-an-existing-network-provide-network-information-to-create-instances-and-the-rest-of-the-stack) Installion flow is executed.

Follow the prompts:

     Please provide the tag Name to Prefix your Stack(Eg:- jazz10 ): jazz123
     Do you need full stack including network(Y/N): n
     Do you have existing Jenkins and Bitbucket Server(Y/N): n
     We will create Jenkins and Bitbucket Servers using the Network Stack you provided
     Please have vpc,subnet and cidr blocks handy
     Please provide VPC id: vpc-e1b9b784
     Please provide subnet id: subnet-c5caafee
     Please provide CIDR BLOCK: 172.31.0.0/16
     
## Scenario 3 - Building stack using existing jenkins/BitBucket instances(provide existing bitbucket/jenkins information to create the rest of the stack).

Note: 

* Please create the following adminid/password on Jenkins Server before you proceed: jenkinsadmin/jenkinsadmin
* Please create the following adminid/password on Bitbucket Server before you proceed: jenkins1/jenkinsadmin
* For your convenience we have provided scripts to create Jenkins/Bitbucket servers to test the scenario using existing network.
Please follow the section,
Create Jenkins/Bitbucket servers for Scenario 3

1. ./run.py

Follow the prompts:

     Please provide the tag Name to Prefix your Stack(Eg:- jazz10 ): jazz700
     Do you need full stack including network(Y/N): n
     Do you have existing Jenkins and Bitbucket Server(Y/N): y
     Please create the following adminid/password on Jenkins Server before you proceed: jenkinsadmin/jenkinsadmin
     Please create the following adminid/password on Bitbucket Server before you proceed: jenkins1/jenkinsadmin
     Press the <ENTER> key to continue...
     Please provide Jenkins Server ELB URL: jazz121-jenkinselb-249111302.us-east-1.elb.amazonaws.com
     Please provide Jenkins Server PublicIp: 54.88.1.198
     Please provide Bitbuckket  Server ELB URL: jazz121-bitbucketelb-1289508647.us-east-1.elb.amazonaws.com
     Please provide bitbucket Server PublicIp: 54.90.228.149




## Additional Information

To know how to 
Create Jenkins/Bitbucket servers for Scenario 3' refer [here](https://github.com/tmobile/jazz-installer/wiki/Jazz-Installation-scenarios#create-jenkinsbitbucket-servers-for-scenario-3)


    
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

# Limitations
* We are creating the stack on us-east-1 region. Because us-east-2 has permission issue with s3 Bucket and Cognito resource is not available in us-west-1 region.
* We have limitation of one stack on a region for an account. (coming soon - this limitation will be removed)

