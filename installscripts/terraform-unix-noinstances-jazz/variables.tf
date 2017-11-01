variable "region" { type = "string" default = "us-east-1" }
variable "bitbucketserver_ami" {
  type = "string"
  default = "ami-65a46e1f"
}
variable "jenkinsserver_ami" {
  type = "string"
  default = "ami-d284bec4"
}
variable "chefconfigDir" {
  type = "string"
  default = "../chefconfig"
}
variable "cookbooksDir" {
  type = "string"
  default = "../cookbooks"
}
variable "keypair" {
  type = "map"

  default = {
    key_name = "ec2_rsa"
    public_key = "../sshkeys/ec2_rsa.pub"
    private_key = "../sshkeys/ec2_rsa.pem"
  }
}
variable "jenkinspropsfile" {
  type = "string"
  default = "../cookbooks/jenkins/files/node/jenkins-conf.properties"
}
variable "jenkinsattribsfile" {
  type = "string"
  default = "../cookbooks/jenkins/attributes/default.rb"
}

variable "jenkinsservermap" {
  type = "map"

  default = {
    jenkins_elb = "jazz13-jenkinselb-1989578044.us-east-1.elb.amazonaws.com"
    jenkins_public_ip = "replace IP here"
    subnet = "subnet-c5caafee"
    security_group = "sg-9f725bee"
	jenkins_ssh_login = "ec2-user"
	jenkins_ssh_key = "../sshkeys/jenkinskey.pem"
  }
}
variable "bitbucketservermap" {
  type = "map"

  default = {
    bitbucket_elb = "jazz13-bitbucketelb-977486464.us-east-1.elb.amazonaws.com"
    bitbucket_public_ip = "replace IP here"
	bitbucket_ssh_login = "ec2-user"
	bitbucket_ssh_key = "../sshkeys/bitbucketkey.pem"
  }
}
variable "lambdaCloudWatchProps" {
  type = "map"
  default = {
        statement_id   = "lambdaFxnPermission"
        action         = "lambda:*"
        function_name  = "cloud-logs-streamer-dev"
        principal      = "logs.us-east-1.amazonaws.com"
  }
}
variable "cognito_pool_username" {
  type = "string"
  default = "cognito_pool_username"
}
variable "cognito_pool_password" {
  type = "string"
  default = "cognito_pool_password"
}
variable "github_branch" { type = "string" default = "development" }
