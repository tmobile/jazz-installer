#
# Cognito resources
#
resource "null_resource" "cognito_user_pool" {

provisioner "local-exec" {
    command = "${var.cognito_cmd}  ${var.envPrefix} ${var.envPrefix}-api-onboarding ${var.cognito_pool_username} ${var.cognito_pool_password} ${var.jenkinspropsfile}"
  }  
provisioner "local-exec" {
    command = "${var.cognito_cmd}  ${var.envPrefix} ${var.envPrefix}-api-onboarding ${var.cognito_pool_username} ${var.cognito_pool_password} ${var.jenkinsjsonpropsfile}"
  }
provisioner "local-exec" {
    when = "destroy"
  command = "${var.cognitoDelete_cmd}  ${var.envPrefix}"
  }

}

