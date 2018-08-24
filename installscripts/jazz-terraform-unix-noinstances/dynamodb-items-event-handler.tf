locals {
  event_handler_names = [
    "CREATE_SERVERLESS_SERVICE",
    "JENKINS",
    "ONBOARDING_API",
    "BITBUCKET",
    "GITLAB",
    "DELETE_SERVICE_API",
    "AWS"
  ]
}

resource "aws_dynamodb_table_item" "event-handler-dev" {
  count = "${length(local.event_handler_names)}"
  table_name = "${aws_dynamodb_table.dynamodb-table_Event_Handler_Dev.name}"
  hash_key = "${aws_dynamodb_table.dynamodb-table_Event_Handler_Dev.hash_key}"
  item = <<ITEM
{
  "EVENT_HANDLER": {"S": "${element(local.event_handler_names, count.index)}"}
}
ITEM
}

resource "aws_dynamodb_table_item" "event-handler-stg" {
  count = "${length(local.event_handler_names)}"
  table_name = "${aws_dynamodb_table.dynamodb-table_Event_Handler_Stg.name}"
  hash_key = "${aws_dynamodb_table.dynamodb-table_Event_Handler_Stg.hash_key}"
  item = <<ITEM
{
  "EVENT_HANDLER": {"S": "${element(local.event_handler_names, count.index)}"}
}
ITEM
}

resource "aws_dynamodb_table_item" "event-handler-prod" {
  count = "${length(local.event_handler_names)}"
  table_name = "${aws_dynamodb_table.dynamodb-table_Event_Handler_Prod.name}"
  hash_key = "${aws_dynamodb_table.dynamodb-table_Event_Handler_Prod.hash_key}"
  item = <<ITEM
{
  "EVENT_HANDLER": {"S": "${element(local.event_handler_names, count.index)}"}
}
ITEM
}
