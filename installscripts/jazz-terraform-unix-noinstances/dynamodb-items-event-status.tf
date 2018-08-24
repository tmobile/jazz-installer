locals {
  event_status_names = [
    "COMPLETED",
    "FAILED",
    "STARTED"
  ]
}

resource "aws_dynamodb_table_item" "event-status-dev" {
  count = "${length(local.event_status_names)}"
  table_name = "${aws_dynamodb_table.dynamodb-table_Event_Status_Dev.name}"
  hash_key = "${aws_dynamodb_table.dynamodb-table_Event_Status_Dev.hash_key}"
  item = <<ITEM
{
  "EVENT_STATUS": {"S": "${element(local.event_status_names, count.index)}"}
}
ITEM
}

resource "aws_dynamodb_table_item" "event-status-stg" {
  count = "${length(local.event_status_names)}"
  table_name = "${aws_dynamodb_table.dynamodb-table_Event_Status_Stg.name}"
  hash_key = "${aws_dynamodb_table.dynamodb-table_Event_Status_Stg.hash_key}"
  item = <<ITEM
{
  "EVENT_STATUS": {"S": "${element(local.event_status_names, count.index)}"}
}
ITEM
}

resource "aws_dynamodb_table_item" "event-status-prod" {
  count = "${length(local.event_status_names)}"
  table_name = "${aws_dynamodb_table.dynamodb-table_Event_Status_Prod.name}"
  hash_key = "${aws_dynamodb_table.dynamodb-table_Event_Status_Prod.hash_key}"
  item = <<ITEM
{
  "EVENT_STATUS": {"S": "${element(local.event_status_names, count.index)}"}
}
ITEM
}
