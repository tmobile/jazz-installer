variable "sets3acl_cmd" {
  type = "string"
  default = "./scripts/sets3acl.sh"
}
variable "modifyCodebase_cmd" {
  type = "string"
  default = "./scripts/modifyCodebase.sh"
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
  default = "./scripts/configureES.py"
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
variable "configureJenkinsCE_cmd" {
  type = "string"
  default = "./scripts/configure-jenkins.sh"
}
variable "configureGitlab_cmd" {
  type = "string"
  default = "./scripts/configure-gitlab.py"
}
variable "configureCodeq_cmd" {
  type = "string"
  default = "./scripts/configure-codeq.py"
}
variable "healthCheck_cmd" {
  type = "string"
  default = "./scripts/health_check.py"
}
variable "pushInstallervars_cmd" {
  type= "string"
  default = "./scripts/pushInstallervars.sh"
}
variable "config_cmd" {
  type = "string"
  default = "./scripts/config.py"
}
variable "cleanEni_cmd" {
  type = "string"
  default = "./scripts/clean_lambda_eni.py"
}
