variable "events" {
  description = "List of event handler records"
  type = "list"
  default = ["CREATE_SERVERLESS_SERVICE", "JENKINS", "ONBOARDING_API", "BITBUCKET", "GITLAB", "DELETE_SERVICE_API", "AWS"]
}

resource "aws_dynamodb_table_item" "aws" {
  count = 7
  table_name = "${aws_dynamodb_table.dynamodb-table_Event_Handler_Dev.name}"
  hash_key = "${aws_dynamodb_table.dynamodb-table_Event_Handler_Dev.hash_key}"
  item = <<ITEM
{
  "EVENT_HANDLER": {"S": "${element(var.events, count.index)}"}
}
ITEM
}
