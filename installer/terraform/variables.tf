#
# General variables
#
variable "region" { type = "string" default = "us-east-1" }
variable "github_branch" { type = "string" default = "development" }
variable "github_repo" {
  type = "string"
  default = "https://github.com/tmobile/jazz.git"
}
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
  default = "./provisioners/cookbooks"
}
variable "chefDestDir" {
  type = "string"
  default = "/tmp/jazz-chef"
}
variable "contentRepo" {
  type = "string"
  default = "https://github.com/tmobile/jazz-content.git"
}
#
# Jenkins related variables
#
variable "jenkinsjsonpropsfile" {
  type = "string"
  default = "./provisioners/cookbooks/jenkins/files/default/jazz-installer-vars.json"
}
variable "jenkinsattribsfile" {
  type = "string"
  default = "./provisioners/cookbooks/jenkins/attributes/default.rb"
}
variable "jenkinsservermap" {
  type = "map"
  default = {
    jenkins_elb = "replace"
    jenkins_rawendpoint = "replace"
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
    sonar_server_elb = "replaceelb"
    sonar_username = "replaceusername"
    sonar_passwd = "replacepasswd"
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
variable "network_range" { type = "string" default = "0.0.0.0/0"}
variable "jenkins_docker_image" {
  type = "string"
  default = "jazzserverless/jazzoss-jenkins:1.0.0"
}
variable "gitlab_docker_image" {
  type = "string"
  default = "gitlab/gitlab-ce:11.3.0-ce.0"
}
variable "codeq_docker_image" {
  type = "string"
  default = "jazzserverless/jazzoss-sonarqube:1.0.0"
}
variable "dockerizedSonarqube" { default = false }
variable "ecsJenkinscpu" { type = "string" default = "1024" }
variable "ecsJenkinsmemory" { type = "string" default = "3072" }
variable "ecsGitlabcpu" { type = "string" default = "512" }
variable "ecsGitlabmemory" { type = "string" default = "3072" }
variable "ecsSonarqubecpu" { type = "string" default = "256" }
variable "ecsSonarqubememory" { type = "string" default = "2048" }
variable "autovpc" { default = false }
variable "vpc_cidr_block" {
  type        = "string"
  default     = "10.0.0.0/16"
}
variable "existing_vpc_ecs" { type = "string" }
variable "acl_db_password" {type = "string"}
variable "acl_db_name" {type = "string" default = "casbin"}
variable "acl_db_username" {type = "string" default = "root"}
variable "acl_db_port" {type = "string" default = "3306"}
variable "response_parameters_cors" {
   type = "map"
   default = {
     "gatewayresponse.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,Jazz-Service-ID'"
     "gatewayresponse.header.Access-Control-Allow-Methods" = "'*'"
     "gatewayresponse.header.Access-Control-Allow-Origin" = "'*'"
  }
 }
variable "es_port_def" {type = "string" default = "9200"}
variable "es_port_tcp" {type = "string" default = "9300"}
variable "kibana_port_def" {type = "string" default = "5601"}
variable "kibana_port_access" {type = "string" default = "80"}
variable "ecsEscpu" { type = "string" default = "2048" }
variable "ecsEsmemory" { type = "string" default = "5120" }
variable "ecsKibanacpu" { type = "string" default = "512" }
variable "ecsKibanamemory" { type = "string" default = "2048" }
variable "es_docker_image" {
  type = "string"
  default = "docker.elastic.co/elasticsearch/elasticsearch:6.5.0"
}
variable "kibana_docker_image" {
  type = "string"
  default = "docker.elastic.co/kibana/kibana:6.5.4"
}
