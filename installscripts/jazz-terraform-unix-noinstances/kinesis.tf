resource "aws_kinesis_stream" "kinesis_stream_dev" {
  name           = "${var.envPrefix}-events-hub-dev"
  shard_count      = 1
  retention_period = 24

  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]

  tags = "${merge(var.additional_tags, local.common_tags)}"
}

resource "aws_kinesis_stream" "kinesis_stream_stg" {
  name           = "${var.envPrefix}-events-hub-stg"
  shard_count      = 1
  retention_period = 24

  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]

  tags = "${merge(var.additional_tags, local.common_tags)}"
}

resource "aws_kinesis_stream" "kinesis_stream_prod" {
  name           = "${var.envPrefix}-events-hub-prod"
  shard_count      = 1
  retention_period = 24

  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]

  tags = "${merge(var.additional_tags, local.common_tags)}"
}

resource "aws_kinesis_stream" "logs_stream_dev" {
  name           = "${var.envPrefix}-logs-streamer-dev"
  shard_count      = 1
  retention_period = 24

  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]

  tags = "${merge(var.additional_tags, local.common_tags)}"
}

resource "aws_kinesis_stream" "logs_stream_stg" {
  name           = "${var.envPrefix}-logs-streamer-stg"
  shard_count      = 1
  retention_period = 24

  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]

  tags = "${merge(var.additional_tags, local.common_tags)}"
}

resource "aws_kinesis_stream" "logs_stream_prod" {
  name           = "${var.envPrefix}-logs-streamer-prod"
  shard_count      = 1
  retention_period = 24

  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]

  tags = "${merge(var.additional_tags, local.common_tags)}"
}

#Tried dynamic list, but found issue - https://github.com/hashicorp/terraform/issues/18682

# PROD
resource "aws_cloudwatch_log_destination" "prod_east1_kinesis" {
  provider = "aws.east1"
  name       = "${var.envPrefix}-prod-us-east-1-kinesis"
  role_arn   = "${aws_iam_role.platform_role.arn}"
  target_arn = "${aws_kinesis_stream.logs_stream_prod.arn}"
}

resource "aws_cloudwatch_log_destination" "prod_west2_kinesis" {
  provider = "aws.west2"
  name       = "${var.envPrefix}-prod-us-west-2-kinesis"
  role_arn   = "${aws_iam_role.platform_role.arn}"
  target_arn = "${aws_kinesis_stream.logs_stream_prod.arn}"
}

#DEV
resource "aws_cloudwatch_log_destination" "dev_east1_kinesis" {
  provider = "aws.east1"
  name       = "${var.envPrefix}-dev-us-east-1-kinesis"
  role_arn   = "${aws_iam_role.platform_role.arn}"
  target_arn = "${aws_kinesis_stream.logs_stream_dev.arn}"
}

resource "aws_cloudwatch_log_destination" "dev_west2_kinesis" {
  provider = "aws.west2"
  name       = "${var.envPrefix}-dev-us-west-2-kinesis"
  role_arn   = "${aws_iam_role.platform_role.arn}"
  target_arn = "${aws_kinesis_stream.logs_stream_dev.arn}"
}

#STG
resource "aws_cloudwatch_log_destination" "stg_east1_kinesis" {
  provider = "aws.east1"
  name       = "${var.envPrefix}-stg-us-east-1-kinesis"
  role_arn   = "${aws_iam_role.platform_role.arn}"
  target_arn = "${aws_kinesis_stream.logs_stream_stg.arn}"
}

resource "aws_cloudwatch_log_destination" "stg_west2_kinesis" {
  provider = "aws.west2"
  name       = "${var.envPrefix}-stg-us-west-2-kinesis"
  role_arn   = "${aws_iam_role.platform_role.arn}"
  target_arn = "${aws_kinesis_stream.logs_stream_stg.arn}"
}
