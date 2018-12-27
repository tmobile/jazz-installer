#
# General variables
#
variable "region" { type = "string" default = "us-east-1" }
variable "github_branch" { type = "string" default = "development" }
variable "github_repo" { type = "string" default = "https://github.com/tmobile/jazz.git" }
variable "aws_access_key" { type = "string" default = "aws_access_key" }
variable "aws_secret_key" { type = "string" default = "aws_secret_key" }
variable "jazz_accountid" { type = "string" default = "jazz_accountid" }

#
# Cognito variables
#
variable "cognito_pool_username" {type = "string" default = "cognito_pool_username"}
variable "cognito_pool_password" {type = "string" default = "cognito_pool_password"}

#
# Chef and Cookbook variables
# Copying these resources to TMP on remote machines,
# since $HOME is not reliable for all of our scenarios.
#

variable "cookbooksSourceDir" {
  type = "string"
  default = "../cookbooks"
}
variable "chefDestDir" {
  type = "string"
  default = "/tmp/jazz-chef"
}
#
# Jenkins related variables
#
variable "jenkinsjsonpropsfile" {
  type = "string"
  default = "../cookbooks/jenkins/files/default/jazz-installer-vars.json"
}
variable "jenkinsattribsfile" {
  type = "string"
  default = "../cookbooks/jenkins/attributes/default.rb"
}
variable "jenkinsservermap" {
  type = "map"
  default = {
    jenkins_elb = "replace"
    jenkins_public_ip = "replaceIP"
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
# SCM common variables
#
variable "scmmap" {
  type = "map"
  default = {
    scm_type = "replacescmtype"
    scm_elb = "replaceelb"
    scm_publicip = "replaceip"
    scm_username = "replaceusername"
    scm_passwd = "replacepasswd"
    scm_privatetoken = "replacetoken"
    scm_slfid = "replaceslfid"
    scm_pathext = "replacescmPathExt"
  }
}

#
# CodeQuality - SonarQube variables
#
variable "codeqmap" {
  type = "map"
  default = {
    codequality_type = "replacecodeqtype"
    sonar_server_elb = "replaceelb"
    sonar_username = "replaceusername"
    sonar_passwd = "replacepasswd"
    sonar_server_public_ip = "replacepubip"
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
        function_name  = "cloud-logs-streamer-prod"
        principal      = "logs.us-east-1.amazonaws.com"
  }
}

# SCM Used. Default is bitbucket
# Set to true for respectively SCMs, and false for bitbucket. This variable decides which terraform block to run for SCM
variable "scmbb" { default = true }
variable "scmgitlab" { default = false }
variable "codeq" { default = false }
variable "atlassian_jar_path" { type = "string" }
variable "dockerizedJenkins" {default = true}
variable "additional_tags" {
  type = "map"
  default = {}
}
variable "aws_tags" { type = "string" }
