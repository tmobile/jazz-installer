resource "aws_api_gateway_rest_api" "jazz-dev" {
  name        = "${var.envPrefix}-dev"
  description = "DEV API Gateway"
}

resource "aws_api_gateway_rest_api" "jazz-stg" {
  name        = "${var.envPrefix}-stg"
  description = "STG API Gateway"
}

resource "aws_api_gateway_rest_api" "jazz-prod" {
  name        = "${var.envPrefix}-prod"
  description = "PROD API Gateway"

  provisioner "local-exec" {
    command = "rm -rf jazz-core"
  }
  provisioner "local-exec" {
    command = "git clone -b ${var.github_branch} ${var.github_repo} jazz-core --depth 1"

  }
  provisioner "local-exec" {
    command = "${var.configureApikey_cmd} ${aws_api_gateway_rest_api.jazz-dev.id} ${aws_api_gateway_rest_api.jazz-stg.id} ${aws_api_gateway_rest_api.jazz-prod.id} ${var.jenkinsjsonpropsfile} ${var.jenkinsattribsfile} ${var.envPrefix}"
  }
}
