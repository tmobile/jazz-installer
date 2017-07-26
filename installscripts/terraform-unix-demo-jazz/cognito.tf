resource "null_resource" "cognito_user_pool" {

provisioner "local-exec" {
    command = "${var.cognito_cmd}  ${var.envPrefix} ${var.envPrefix}-api-onboarding jazzuser Welcome@2Jazz ${var.jenkinspropsfile}"
  }  
provisioner "local-exec" {
    when = "destroy"
  command = "${var.cognitoDelete_cmd}  ${var.envPrefix}"
  }

}

