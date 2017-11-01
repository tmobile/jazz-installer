variable "region" {
  type = "string"
  default = "us-east-1"
}
/* moved to netVars.tf
variable "vpc" {
  type = "string"
  // us-east-1
  default = "vpc-0b157572"
  //us-west-2 -- oregon
//  default = "vpc-c7e4b0a2"
}
variable "subnet" {
  type = "string"
        // us-east-1
  default = "subnet-3127b16b"
        // us-east-2
  //default = "subnet-24cfea41"
}
variable "cidrblocks" {
  type = "string"
  default = "10.0.0.0/16"
}
*/
variable "bitbucketserver_ami" {
  type = "string"
	// ami in us-east1 with licenses and addons licenses
  default = "ami-9ba986e0"
	// ami copied to us-west-1 with licenses and addons
  //default = "ami-74755c14"
}
variable "jenkinsserver_ami" {
  type = "string"
	// ami in us-east-1
  default = "ami-5a293a21"
	// amis copied to us-west-1
 // default = "ami-ae745dce"
}
variable "jenkinsslave_ami" {
  type = "string"
  default = "ami-4d35095b"
}
variable "bitbucket_home" {
  type = "string"
  default = "/home/ec2-user/atlassian/application-data/bitbucket"
}
variable "bitbucket_defaultInstallDir" {
  type = "string"
  default = "/home/ec2-user/atlassian/bitbucket/5.2"
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
variable "cognito_pool_username" {
  type = "string"
  default = "jazzuser"
}
variable "cognito_pool_password" {
  type = "string"
  default = "Welcome@2Jazz"
}
variable "github_branch" { type = "string" default = "development" }
