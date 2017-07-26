New Repository for Serverless Framework.
Base line code to be Uploaded into the REPO as on Date Jun 7th 2016.
## Jazz Serverless Development Framework

# Prerequisites
# Setup Installer Box
* Install aws cli
* Install Terraform
* Install Packer
*  Install jdk1.8
* Install git
* Create AWS account with necessary permissions and run aws configure to set the access key, secret key, region and output format      
* The AWS account should have permission to AMIs and to create the following AWS Resources in us-east-1 region.
* Update AWS credentials (Access Key/Secret Key) in the ‘aws.sh’ file
SLF/installscripts/cookbooks/jenkins/files/credentials/aws.sh
* Use RHEL 7 instance as your installer box. The software required on the installer box in listed below

        UnZip 6.00
        git 2.9.4
        curl 7.29.0
        apache-maven-3.5.0
        Java version: 1.8.0_131
        npm 5.0.3
        node v8.1.3
        aws cli
        aws api gateway importer
        install serverless using npm install
        Terraform_0.9.11
        Packer_1.0.2
        Atlassian-cli-6.7.1
        jq-1.5

* Use your Gitlab account to clone the repo     


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
We are creating the stack on us-east-1 region. Because us-east-2 has permission issue with s3 Bucket and Cognito resource is not available in us-west-1 region.
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

# Stack Creation Scenarios
# Provide access to the following AMIS for your account
            ami-d284bec4
            ami-d284bec4
            
**Flow 1** : Build stack with new Bitbucket and Jenkins Server in existing VPC and Subnet
* Git clone SLF repo branch patch-5
 
        git clone -b patch-5 https://gitlab.com/ustslf/SLF.git
![font samples - light](https://gitlab.com/ustslf/SLF/raw/patch-5/screenshots/GitLab.png)
* Change the permission for sshkeys in ./SLF/installscripts/sshkeys

        chmod 400 ./SLF/installscripts/sshkeys/*
  ![font samples - light](https://gitlab.com/ustslf/SLF/raw/patch-5/screenshots/chmod.png)            
* Update AWS credentials (Access Key/Secret Key) in the ‘aws.sh’ file

        SLF/installscripts/cookbooks/jenkins/files/credentials/aws.sh
  ![font samples - light](https://gitlab.com/ustslf/SLF/raw/patch-5/screenshots/aws_key.png)
      
* Update the envPrefix, region, VPC ID, Subnet ID & CIDR Block  in variables.tf file.
    envPrefix is the tag used to tag all the artifacts in the stack being created.
        ./SLF/installscripts/terraform-unix-demo-jazz/variables.tf

        variable "region" {
          type = "string"
          default = "us-east-1"
        }
        variable "envPrefix" {
          type = "string"
          default = "       jazz2"
        }
        variable "vpc" {
          type = "string"
          default = "xxxxxx"
        }
        variable "subnet" {
          type = "string"
          default = "xxxxxx"
        }
        variable "cidrblocks" {
          type = "string"
          default = "xxxxxx"
        }
  ![font samples - light](https://gitlab.com/ustslf/SLF/raw/patch-5/screenshots/variables.png)        
* Change to directory ./SLF/installscripts/terraform-unix-demo-jazz and run command to bring the stack up

        nohup  terraform apply  &
  ![font samples - light](https://gitlab.com/ustslf/SLF/raw/patch-5/screenshots/jazz_terraform_apply.png)        
* To check the stack building logs 

        tail -f nohup.out
  ![font samples - light](https://gitlab.com/ustslf/SLF/raw/patch-5/screenshots/jazz_tail_file.png)
  
**Flow 2**. Build Stack with Existing Bitbucket and Jenkins server
* Cd /home/ec2-user/SLF/installscripts/terraform-unix-noinstances-jazz
* Provide the Existing Bitbucket Server/ Jenkins Server info in variables.tf


        variable "envPrefix" {
          type = "string"
          default = "jazz3"
        }
        
        variable "jenkinsservermap" {
          type = "map"
        
          default = {
            jenkins_elb = "xxxxxxxx"
            public_ip = "xxxxxxxx"
            subnet = "xxxxxxxx"
            security_group = "xxxxxxxx"
          }
        }
        variable "bitbucketservermap" {
          type = "map"
        
          default = {
            bitbucket_elb = "xxxxxxxx"
            public_ip = "xxxxxxxx"
          }
        }
  ![font samples - light](https://gitlab.com/ustslf/SLF/raw/patch-5/screenshots/env-prefix.png)
  ![font samples - light](https://gitlab.com/ustslf/SLF/raw/patch-5/screenshots/bitbucket-elb.png)
  ![font samples - light](https://gitlab.com/ustslf/SLF/raw/patch-5/screenshots/jenkins-elb.png)
* If the lambda permission is already applied to the billing account, please comment out the following in variable.tf file
    ./SLF/installscripts/terraform-unix-noinstances-jazz/variables.tf

        variable "lambdaCloudWatchProps" {
          type = "map"
          default = {
                statement_id   = "lambdaFxnPermission"
                action         = "lambda:*"
                function_name  = "cloud-logs-streamer-dev"
                principal      = "logs.us-east-1.amazonaws.com"
          }
  ![font samples - light](https://gitlab.com/ustslf/SLF/raw/patch-5/screenshots/lambda_permissions.png)           
* Rename the file lamdbapermissions.tf to lamdbapermissions.tf1

        mv lamdbapermissions.tf lamdbapermissions.tf1
  ![font samples - light](https://gitlab.com/ustslf/SLF/raw/patch-5/screenshots/rename_file.png)        

* Change to directory ./SLF/installscripts/terraform-unix-noinstances-jazz run command to bring the stack up

        nohup  terraform apply  &
  ![font samples - light](https://gitlab.com/ustslf/SLF/raw/patch-5/screenshots/jazz_terrafor_apply_no-instances.png)
* To check the stack building logs 

        tail -f nohup.out
  ![font samples - light](https://gitlab.com/ustslf/SLF/raw/patch-5/screenshots/jazz_tail_file_no-instances.png)
* The following software should be installed on the existing bitbucket server
 
         chefdk - 1.4.3
         git 2.9.4
         Java version: 1.8.0_131
         atlassian-bitbucket-5.0.2
* Please install the following addons as well

        Bitbucket CLI Connector
        bitbucket-webhooks
        Bitbucket Web Post Hooks Plugin

* On the existing bitbucket server please create  admin user with

        userid : jenkins1
        password jenkinsadmin. 
* On the Jenkins Server please install the following 

        chefdk - 1.4.3
        UnZip 6.00
        git 2.9.4
        curl 7.29.0
        apache-maven-3.5.0
        Java version: 1.8.0_131
        npm 5.0.3
        node v8.1.3
        aws cli
        aws api gateway importer
        install serverless using npm install
        opensource jenkins -2.68
* Please ensure the following plugins exist in the Jenkins Server. If not please install the missing ones

        bouncycastle-api
        pipeline-input-step
        cloudbees-folder
        branch-api
        structs
        docker-commons
        junit
        antisamy-markup-formatter
        pam-auth
        windows-slaves
        pipeline-build-step
        display-url-api
        docker-workflow
        mailer
        ldap
        token-macro
        external-monitor-job
        icon-shim
        matrix-auth
        pipeline-model-api
        script-security
        matrix-project
        build-timeout
        credentials
        ssh-credentials
        workflow-step-api
        plain-credentials
        git-client
        credentials-binding
        timestamper
        jackson2-api
        scm-api
        workflow-api
        workflow-support
        github-api
        durable-task
        workflow-durable-task-step
        git-server
        resource-disposer
        ws-cleanup
        ant
        git
        gradle
        workflow-cps
        pipeline-milestone-step
        workflow-cps-global-lib
        jquery-detached
        ace-editor
        workflow-scm-step
        pipeline-stage-step
        github
        workflow-job
        pipeline-stage-view
        pipeline-graph-analysis
        pipeline-rest-api
        handlebars
        momentjs
        pipeline-model-extensions
        workflow-multibranch
        authentication-tokens
        pipeline-stage-tags-metadata
        pipeline-model-declarative-agent
        workflow-basic-steps
        pipeline-model-definition
        workflow-aggregator
        github-branch-source
        pipeline-github-lib
        mapdb-api
        subversion
        ssh-slaves
        email-ext
        config-file-provider
        pipeline-npm
        mercurial
        cloudbees-bitbucket-branch-source
        bitbucket
        envinject
        build-user-vars-plugin
        javadoc
        jquery
        extended-choice-parameter
        aws-java-sdk
        aws-credentials
        cloudbees-credentials

* On the Jenkins Server please create an admin user

        Userid: jenkinsadmin
        Password: jenkinsadmin


