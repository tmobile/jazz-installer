locals {
  event_type_names = [
    "SERVICE_UPDATE",
    "SERVICE_DEPLOYMENT",
    "SERVICE_CREATION",
    "SERVICE_DELETION",
    "SERVICE_ONBOARDING"
  ]
}

resource "aws_dynamodb_table_item" "event-type-dev" { YOOP
  count = "${length(local.event_type_names)}"
  table_name = "${aws_dynamodb_table.dynamodb-table_Event_Type_Dev.name}"
  hash_key = "${aws_dynamodb_table.dynamodb-table_Event_Type_Dev.hash_key}"
  item = <<ITEM
{
  "EVENT_TYPE": {"S": "${element(local.event_type_names, count.index)}"}
}
ITEM
}

resource "aws_dynamodb_table_item" "event-type-stg" {
  count = "${length(local.event_type_names)}"
  table_name = "${aws_dynamodb_table.dynamodb-table_Event_Type_Stg.name}"
  hash_key = "${aws_dynamodb_table.dynamodb-table_Event_Type_Stg.hash_key}"
  item = <<ITEM
{
  "EVENT_TYPE": {"S": "${element(local.event_type_names, count.index)}"}
}
ITEM
}

resource "aws_dynamodb_table_item" "event-type-prod" {
  count = "${length(local.event_type_names)}"
  table_name = "${aws_dynamodb_table.dynamodb-table_Event_Type_Prod.name}"
  hash_key = "${aws_dynamodb_table.dynamodb-table_Event_Type_Prod.hash_key}"
  item = <<ITEM
{
  "EVENT_TYPE": {"S": "${element(local.event_type_names, count.index)}"}
}
ITEM
}
