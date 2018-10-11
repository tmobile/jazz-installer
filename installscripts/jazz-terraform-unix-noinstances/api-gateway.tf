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
}
