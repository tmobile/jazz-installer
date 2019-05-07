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

resource "aws_api_gateway_gateway_response" "jazz-dev-4xx" {
  rest_api_id   = "${aws_api_gateway_rest_api.jazz-dev.id}"
  status_code   = ""
  response_type = "DEFAULT_4XX"
  response_parameters = "${var.response_parameters_cors}"
}

resource "aws_api_gateway_gateway_response" "jazz-stg-4xx" {
  rest_api_id   = "${aws_api_gateway_rest_api.jazz-stg.id}"
  status_code   = ""
  response_type = "DEFAULT_4XX"
  response_parameters = "${var.response_parameters_cors}"
}

resource "aws_api_gateway_gateway_response" "jazz-prod-4xx" {
  rest_api_id   = "${aws_api_gateway_rest_api.jazz-prod.id}"
  status_code   = ""
  response_type = "DEFAULT_4XX"
  response_parameters = "${var.response_parameters_cors}"
}

resource "aws_api_gateway_gateway_response" "jazz-dev-5xx" {
  rest_api_id   = "${aws_api_gateway_rest_api.jazz-dev.id}"
  status_code   = ""
  response_type = "DEFAULT_5XX"
  response_parameters = "${var.response_parameters_cors}"
}

resource "aws_api_gateway_gateway_response" "jazz-stg-5xx" {
  rest_api_id   = "${aws_api_gateway_rest_api.jazz-stg.id}"
  status_code   = ""
  response_type = "DEFAULT_5XX"
  response_parameters = "${var.response_parameters_cors}"
}

resource "aws_api_gateway_gateway_response" "jazz-prod-5xx" {
  rest_api_id   = "${aws_api_gateway_rest_api.jazz-prod.id}"
  status_code   = ""
  response_type = "DEFAULT_5XX"
  response_parameters = "${var.response_parameters_cors}"
}


resource "aws_cloudwatch_log_group" "API-Gateway-Execution-Logs_dev" {
  name = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.jazz-dev.id}/dev"
  tags = "${merge(var.additional_tags, local.common_tags)}"
}

resource "aws_cloudwatch_log_group" "API-Gateway-Execution-Logs_stg" {
  name = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.jazz-stg.id}/stg"
  tags = "${merge(var.additional_tags, local.common_tags)}"
}

resource "aws_cloudwatch_log_group" "API-Gateway-Execution-Logs_prod" {
  name = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.jazz-prod.id}/prod"
  tags = "${merge(var.additional_tags, local.common_tags)}"
}

resource "aws_cloudwatch_log_subscription_filter" "logfilter-dev" {
  name            = "logfilter-dev"
  role_arn        = "${aws_iam_role.platform_role.arn}"
  log_group_name  = "${aws_cloudwatch_log_group.API-Gateway-Execution-Logs_dev.name}"
  filter_pattern  = ""
  destination_arn = "${aws_kinesis_stream.logs_stream_prod.arn}"
  distribution    = "Random"
}

resource "aws_cloudwatch_log_subscription_filter" "logfilter-stg" {
  name            = "logfilter-stg"
  role_arn        = "${aws_iam_role.platform_role.arn}"
  log_group_name  = "${aws_cloudwatch_log_group.API-Gateway-Execution-Logs_stg.name}"
  filter_pattern  = ""
  destination_arn = "${aws_kinesis_stream.logs_stream_prod.arn}"
  distribution    = "Random"
}

resource "aws_cloudwatch_log_subscription_filter" "logfilter-prod" {
  name            = "logfilter-prod"
  role_arn        = "${aws_iam_role.platform_role.arn}"
  log_group_name  = "${aws_cloudwatch_log_group.API-Gateway-Execution-Logs_prod.name}"
  filter_pattern  = ""
  destination_arn = "${aws_kinesis_stream.logs_stream_prod.arn}"
  distribution    = "Random"
}

resource "aws_api_gateway_account" "cloudwatchlogroleupdate" {
  cloudwatch_role_arn = "${aws_iam_role.platform_role.arn}"
}
