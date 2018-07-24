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
