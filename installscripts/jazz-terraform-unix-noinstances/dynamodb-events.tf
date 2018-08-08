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

resource "aws_dynamodb_table_item" "aws" {
  count = "${length(local.event_handler_names)}"
  table_name = "${aws_dynamodb_table.dynamodb-table_Event_Handler_Dev.name}"
  hash_key = "${aws_dynamodb_table.dynamodb-table_Event_Handler_Dev.hash_key}"
  item = <<ITEM
{
  "EVENT_HANDLER": {"S": "${element(local.event_handler_names, count.index)}"}
}
ITEM
}
