variable "bitbucketserver_ami" {
  type = "string"
//  default = "ami-06360a10"
  default = "ami-50c7cb46"
}
variable "jenkinsserver_ami" {
  type = "string"
  default = "ami-d284bec4"
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

