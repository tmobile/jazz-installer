variable "configureS3Names_cmd" {
  type = "string"
  default = "./scripts/configureS3Names.sh"
}
variable "configureSubnet_cmd" {
  type = "string"
  default = "./scripts/configureSubnet.sh"
}
variable "sets3acl_cmd" {
  type = "string"
  default = "./scripts/sets3acl.sh"
}
variable "configurescmelb_cmd" {
  type = "string"
  default = "./scripts/configurescmelb.sh"
}
variable "configureApikey_cmd" {
  type = "string"
  default = "./scripts/configureApikey.sh"
}
variable "configureSonar_cmd" {
  type = "string"
  default = "./scripts/configureSonar.sh"
}
variable "configureKinesis_cmd" {
  type = "string"
  default = "./scripts/configureKinesis.sh"
}
variable "modifyCodebase_cmd" {
  type = "string"
  default = "./scripts/modifyCodebase.sh"
}
variable "configureJenkinselb_cmd" {
  type = "string"
  default = "./scripts/configureJenkinselb.sh"
}
variable "scmclient_cmd" {
  type = "string"
  default = "./scripts/scmclient.sh"
}
variable "scmpush_cmd" {
  type = "string"
  default = "./scripts/scmpush.sh"
}
variable "configureESEndpoint_cmd" {
  type = "string"
  default = "./scripts/configureESEndpoint.sh"
}
variable "cognito_cmd" {
  type = "string"
  default = "./scripts/cognito.sh"
}
variable "deployS3Webapp_cmd" {
  type = "string"
  default = "./scripts/deployS3Webapp.sh"
}
variable "modifyPropertyFile_cmd" {
  type = "string"
  default = "./scripts/modifyPropertyFile.sh"
}
variable "ses_cmd" {
  type = "string"
  default = "./scripts/ses.sh"
}
variable "injectingBootstrapToJenkinsfiles_cmd" {
  type = "string"
  default = "./scripts/injectingToJenkinsfile.sh"
}
variable "launchJenkinsCE_cmd" {
  type = "string"
  default = "../dockerfiles/jenkins-ce/chefclient.sh"
}
variable "pushInstallervars_cmd" {
  type= "string"
  default = "./scripts/pushInstallervars.sh"
}
variable "configureJenkinscontainer_cmd" {
  type = "string"
  default = "./scripts/configureJenkinscontainer.sh"
}
