variable "configureS3Names_cmd" {
  type = "string"
  default = "./scripts/configureS3Names.sh"
}
variable "sets3acl_cmd" {
  type = "string"
  default = "./scripts/sets3acl.sh"
}
variable "configurebitbucketelb_cmd" {
  type = "string"
  default = "./scripts/configurebitbucketelb.sh"
}
variable "configureApikey_cmd" {
  type = "string"
  default = "./scripts/configureApikey.sh"
}
variable "configureapidoc_cmd" {
  type = "string"
  default = "./scripts/configure-api-doc.sh"
}
variable "modifyCodebase_cmd" {
  type = "string"
  default = "./scripts/modifyCodebase.sh"
}
variable "configureJenkinselb_cmd" {
  type = "string"
  default = "./scripts/configureJenkinselb.sh"
}
variable "configureJenkinsSSHUser_cmd" {
  type = "string"
  default = "./scripts/configureJenkinsSSHUser.sh"
}
variable "bitbucketclient_cmd" {
  type = "string"
  default = "./scripts/bitbucketclient.sh"
}
variable "bitbucketpush_cmd" {
  type = "string"
  default = "./scripts/bitbucketpush.sh"
}

variable "configureESEndpoint_cmd" {
  type = "string"
  default = "./scripts/configureESEndpoint.sh"
}
variable "cognito_cmd" {
  type = "string"
  default = "./scripts/cognito.sh"
}
variable "cognitoDelete_cmd" {
  type = "string"
  default = "./scripts/cognitoDelete.sh"
}
variable "deployS3Webapp_cmd" {
  type = "string"
  default = "./scripts/deployS3Webapp.sh"
}
variable "dynamodb_cmd" {
  type = "string"
  default = "./scripts/dynamodb.sh"
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
