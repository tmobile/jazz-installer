variable "region" {
  type = "string"
  default = "us-east-1"
}
variable "envPrefix" {
  type = "string"
  default = "jazz60"
}
variable "bitbucketserver_ami" {
  type = "string"
  default = "ami-06360a10"
	// amis copied to us-west-1
  //default = "ami-74755c14"
}
variable "jenkinsserver_ami" {
  type = "string"
  default = "ami-d284bec4"
	// amis copied to us-west-1
  //default = "ami-ae745dce"
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
    key_name = "ustglobal_rsa"
    public_key = "../sshkeys/ustglobal_rsa.pub"
    private_key = "../sshkeys/ustglobal_rsa.pem"
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
    jenkins_public_ip = "54.210.15.20"
    subnet = "subnet-c5caafee"
    security_group = "sg-9f725bee"
  }
}
variable "bitbucketservermap" {
  type = "map"

  default = {
    bitbucket_elb = "jazz13-bitbucketelb-977486464.us-east-1.elb.amazonaws.com"
    bitbucket_public_ip = "54.163.38.213"
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
  default = "jazzuser"
}
variable "cognito_pool_password" {
  type = "string"
  default = "Welcome@2Jazz"
}
