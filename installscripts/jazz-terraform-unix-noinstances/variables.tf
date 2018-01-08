#
# The following variable default value would be overwritten
# Hence its added as one line
#
variable "region" { type = "string" default = "us-east-1" }
variable "github_branch" { type = "string" default = "development" }
variable "aws_access_key" { type = "string" default = "aws_access_key" }
variable "aws_secret_key" { type = "string" default = "aws_secret_key" }
variable "jazz_accountid" { type = "string" default = "jazz_accountid" }

#
#Cognito variables
#
variable "cognito_pool_username" {
  type = "string"
  default = "cognito_pool_username"
}
variable "cognito_pool_password" {
  type = "string"
  default = "cognito_pool_password"
}

#
# Chef and Cookbook variables
#
variable "chefconfigDir" {
  type = "string"
  default = "../chefconfig"
}
variable "cookbooksDir" {
  type = "string"
  default = "../cookbooks"
}

#
# Jenkins related variables
#
variable "jenkinspropsfile" {
  type = "string"
  default = "../cookbooks/jenkins/files/node/jenkins-conf.properties"
}
variable "jenkinsjsonpropsfile" {
  type = "string"
  default = "../cookbooks/jenkins/files/node/jazz-installer-vars.json"
}
variable "jenkinsattribsfile" {
  type = "string"
  default = "../cookbooks/jenkins/attributes/default.rb"
}
variable "jenkinsclientrbfile" {
  type = "string"
  default = "../chefconfig/jenkins_client.rb"
}
variable "jenkinsservermap" {
  type = "map"
  default = {
    jenkins_elb = "replace"
    jenkins_public_ip = "replace IP here"
    jenkins_subnet = "replace"
    jenkins_security_group = "replace"
    jenkinsuser = "replace"
    jenkinspasswd = "replace"
    jenkins_ssh_login = "replace"
    jenkins_ssh_port = "22"
    jenkins_ssh_key = "../sshkeys/jenkinskey.pem"
  }
}

#
# Bitbucket related variables
#
variable "bitbucketservermap" {
  type = "map"
  default = {
    bitbucket_elb = "replace ELB here"
    bitbucket_public_ip = "replace IP here"
    bitbucketuser = "replace"
    bitbucketpasswd = "replace"
  }
}

# Gitlab related variables
variable "gitlabservermap" {
  type = "map"
  default = {
    gitlab_public_ip = "replace IP here"
    gitlabuser = "replace"
    gitlabpasswd = "replace"
  }
}

#
# AWS resource variables
#
variable "lambdaCloudWatchProps" {
  type = "map"
  default = {
        statement_id   = "lambdaFxnPermission"
        action         = "lambda:*"
        function_name  = "cloud-logs-streamer-dev"
        principal      = "logs.us-east-1.amazonaws.com"
  }
}

# SCM Used. Default is bitbucket
# Set to true for respectively SCMs, and false for bitbucket. This variable decides which terraform block to run for SCM
variable "scmbb" { default = true }
variable "scmgitlab" { default = false }
