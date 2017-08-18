# Jazz - Developer Preview - Overview

Jazz Installer - sets up the Jazz Serverless Developer Framework for API Services in AWS Cloud.
For more details on Jazz Serverless Development Framework, please refer [here](https://github.com/tmobile/jazz-core/wiki).

*Note: Please go through [limitations](#limitations) before you proceed.*

 *[Make sure prerequisites are met before you proceed with the installation](#prerequisites)* 


# jazz-installer

Installation is a two step process.

 1. [Setup the RHEL 7 server with the installer](#setup-the-rhel-7-server-with-the-installer)
 2. Run the Installation Wizard to install the Framework.
   Choose from the one of the following supported scenario's:
        
    a) [Scenario 1](#scenario-1---building-full-stack-network-instances-and-the-rest-of-the-stack)- Building full stack (Network, Instances and the rest of the stack).

    b) [Scenario 2](#scenario-2---building-stack-in-an-existing-network-provide-network-information-to-create-instances-and-the-rest-of-the-stack) - Building stack in an existing Network (provide Network information to create instances and the rest of the stack).

    c) [Scenario 3](#scenario-3---building-stack-using-existing-jenkinsbitbucket-instancesprovide-existing-bitbucketjenkins-information-to-create-the-rest-of-the-stack) - Building stack using existing jenkins/BitBucket instances(provide existing bitbucket/jenkins information to create the rest of the stack).


# Prerequisites
* Create AWS account with permissions/privileges to create the 
  [AWS Resources](#aws-resources) (listed below) in us-east-1 region. 
* Use RHEL 7 instance as your installer box. More details please refer [here](https://github.com/tmobile/jazz-installer/wiki/Launch-AWS-RHEL7-Instance-for-Installer)
* SSH to RHEL 7 instance and follow steps with 4 commands

# Setup the RHEL 7 server with the installer

Execute the below Command. The first command to be executed inside RHEL 7 instance, which will install all required softwares in the RHEL server and will also clone the repository.

 1. curl -L https://raw.githubusercontent.com/tmobile/jazz-installer/master/installscripts/terraforminstaller/rhel7Installer.sh?token=AcuYLfUy56QFj_7wyw-tWDapxZV-triUks5ZnYtmwA%3D%3D -o rhel7Installer.sh && chmod +x rhel7Installer.sh && ./rhel7Installer.sh && cd ./jazz-installer/installscripts/wizard && ./run.py
  
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
		
 
## Scenario 1 - Building full stack (Network, Instances and the rest of the stack).
  Follow the prompts: (Please use only lowercase alphabets & numbers for tag Name. Some of the artifacts are named using this and AWS has restrictions on the name. Please check AWS console if there are artifacts created with this name. If yes please choose another name)

 
     Please provide the tag Name to Prefix your Stack(Eg:- jazz10 ): jazz123
     Do you need full stack including network(Y/N): Y
     
 Note: 
 * If the CIDR already exists, the script will exit with the following message,
 
     **cidrcheck command =  aws ec2 describe-subnets --filters Name=cidrBlock,Values=10.0.0.0/16 --output=text > ./cidrexists
     default CIDR 10.0.0.0/16 already exists. Please try creating the stack again by providing own subnet**
    
     
## Scenario 2 - Building stack in an existing Network (provide Network information to create instances and the rest of the stack).
1. ./run.py

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
     
## Create Jenkins/Bitbucket servers for Scenario 3

      cd ./jazz-installer/installscripts/terraform-unix-existinginstances-jazz/
    
* Change the text **"replace here"** with proper values in envprefix.tf

      variable "envPrefix" { type = "string" default = "replace here" }
      variable "tagsOwner" { type = "string" default = "replace here" }
      
* Change the VPC, Subnet and CIDR with proper values in variables.tf

      variable "vpc" {
      type = "string"
      default = "**vpc-e1b9b784**"   // us-east-1
      }
      variable "subnet" {
      type = "string"
      default = "**subnet-c5caafee**"         // us-east-1
      }
      variable "cidrblocks" {
      type = "string"
      default = "**172.31.0.0/16**"
      }
      
* Execute the following in ./jazz-installer/installscripts/terraform-unix-existinginstances-jazz/       
      
      nohup ./scripts/create.sh &
     
* Once the script is complete, please pick the values from **./jazz-installer/installscripts/terraform-unix-existinginstances-jazz/settings.txt**

    
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

# Stack Creation Flow
Terraform will create the stack with the following AWS resources,

    AWS::Cognito
    Cognito_user_pool
    AWS::EC2::SecurityGroup
    Aws_security_group.bitbucketelb
    Aws_security_group.jenkins
    Aws_security_group.bitbucket
    Aws_security_group.jenkinselb
    AWS::S3::Bucket
    Aws_s3_bucket.cloudfrontlogs
    AWS::DynamoDB
    Aws_dynamodb_table.dynamodb-table-stg
    Aws_dynamodb_table.dynamodb-table-dev
    Aws_dynamodb_table.dynamodb-table-prod
    AWS::ApiGateway
    Aws_api_gateway_rest_api.jazz-dev
    Aws_api_gateway_rest_api.jazz-prod
    Aws_api_gateway_rest_api.jazz-stag
    AWS::Lambda
    Aws_iam_role.lambda_role
    AWS::S3::Bucket
    Aws_s3_bucket.oab-apis-deployment-dev
    Aws_s3_bucket.oab-apis-deployment-stg
    Aws_s3_bucket.oab-apis-deployment-prod
    Aws_s3_bucket.jazz-web
    AWS::CloudFront
    Aws_cloudfront_origin_access_identity.origin_access_identity
    Aws_cloudfront_distribution.jazz
    AWS::IAM::Policy
    Aws_iam_role_policy_attachment.apigatewayinvokefullAccess
    Aws_iam_role_policy_attachment.lambdafullaccess
    Aws_iam_role_policy_attachment.cloudwatchlogaccess
    AWS::ElasticLoadBalancing::LoadBalancer
    Aws_elb.bitbucketelb
    Aws_elb.jenkinselb
    AWS::Elasticsearch::Domain
    Aws_elasticsearch_domain
    Aws_elasticsearch_domain_policy.elasticsearchdomain_policy
    AWS::EC2::Instance
    Aws_instance.bitbucketserver
    Aws_instance.jenkinsserver
    AWS::ElasticLoadBalancing::LoadBalancer
    Aws_elb_attachment.jenkins
    Aws_elb_attachment.bitbucket

