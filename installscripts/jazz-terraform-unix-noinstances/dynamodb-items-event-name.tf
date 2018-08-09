locals {
  event_name_names = [
    "MODIFY_TEMPLATE",
    "TRIGGER_FOLDERINDEX",
    "CALL_ONBOARDING_WORKFLOW",
    "ONBOARDING_COMPLETED",
    "RAISE_PR",
    "VALIDATE_INPUT",
    "CALL_ONBOARDING_SERVICE",
    "ADD_WRITE_PERMISSIONS_TO_SERVICE_REPO",
    "CREATE_SERVICE",
    "UPDATE_ASSET",
    "BUILD_MASTER_BRANCH",
    "COMMIT_CODE",
    "APPROVE_PR",
    "CREATE_SERVICE_REPO",
    "CALL_DELETE_WORKFLOW",
    "LOCK_MASTER_BRANCH",
    "DEPLOY_TO_AWS",
    "BUILD_CODE_BRANCH",
    "ONBOARDING",
    "PUSH_TEMPLATE_TO_SERVICE_REPO",
    "CREATE_ASSET",
    "CLONE_TEMPLATE",
    "DELETE_PROJECT",
    "BUILD",
    "VALIDATE_PRE_BUILD_CONF",
    "CREATE_BRANCH",
    "CREATE_TAG",
    "COMMIT_TEMPLATE",
    "DELETE_BRANCH",
    "MERGE_PR",
    "DECLINE_PR",
    "UPDATE_PR",
    "COMMENT_PR",
    "DELETE_TAG",
    "CREATE_DEPLOYMENT",
    "UPDATE_DEPLOYMENT",
    "UPDATE_ENVIRONMENT",
    "DELETE_ENVIRONMENT",
    "CALL_DELETE_ENV_WORKFLOW"
  ]
}

resource "aws_dynamodb_table_item" "event-name-dev" {
  count = "${length(local.event_name_names)}"
  table_name = "${aws_dynamodb_table.dynamodb-table_Event_Name_Dev.name}"
  hash_key = "${aws_dynamodb_table.dynamodb-table_Event_Name_Dev.hash_key}"
  item = <<ITEM
{
  "EVENT_NAME": {"S": "${element(local.event_name_names, count.index)}"}
}
ITEM
}

resource "aws_dynamodb_table_item" "event-name-stg" {
  count = "${length(local.event_name_names)}"
  table_name = "${aws_dynamodb_table.dynamodb-table_Event_Name_Stg.name}"
  hash_key = "${aws_dynamodb_table.dynamodb-table_Event_Name_Stg.hash_key}"
  item = <<ITEM
{
  "EVENT_NAME": {"S": "${element(local.event_name_names, count.index)}"}
}
ITEM
}

resource "aws_dynamodb_table_item" "event-name-prod" {
  count = "${length(local.event_name_names)}"
  table_name = "${aws_dynamodb_table.dynamodb-table_Event_Name_Prod.name}"
  hash_key = "${aws_dynamodb_table.dynamodb-table_Event_Name_Prod.hash_key}"
  item = <<ITEM
{
  "EVENT_NAME": {"S": "${element(local.event_name_names, count.index)}"}
}
ITEM
}
