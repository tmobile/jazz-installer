resource "aws_dynamodb_table" "dynamodb-table-dev" {
  name           = "${var.envPrefix}_services_dev"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "SERVICE_ID"

  attribute {
    name = "SERVICE_ID"
    type = "S"
  }

  tags = "${merge(var.additional_tags, local.common_tags)}"
}

resource "aws_dynamodb_table" "dynamodb-table-stg" {
  name           = "${var.envPrefix}_services_stg"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "SERVICE_ID"

  attribute {
    name = "SERVICE_ID"
    type = "S"
  }

  tags = "${merge(var.additional_tags, local.common_tags)}"
}

resource "aws_dynamodb_table" "dynamodb-table-prod" {
  name           = "${var.envPrefix}_services_prod"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "SERVICE_ID"

  attribute {
    name = "SERVICE_ID"
    type = "S"
  }

  tags = "${merge(var.additional_tags, local.common_tags)}"
}

resource "aws_dynamodb_table" "dynamodb-table_Event_Handler_Dev" {
  name           = "${var.envPrefix}_Event_Handler_Dev"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "EVENT_HANDLER"

  attribute {
    name = "EVENT_HANDLER"
    type = "S"
  }

  tags = "${merge(var.additional_tags, local.common_tags)}"
}

resource "aws_dynamodb_table" "dynamodb-table_Event_Handler_Stg" {
  name           = "${var.envPrefix}_Event_Handler_Stg"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "EVENT_HANDLER"

  attribute {
    name = "EVENT_HANDLER"
    type = "S"
  }

  tags = "${merge(var.additional_tags, local.common_tags)}"
}

resource "aws_dynamodb_table" "dynamodb-table_Event_Handler_Prod" {
  name           = "${var.envPrefix}_Event_Handler_Prod"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "EVENT_HANDLER"

  attribute {
    name = "EVENT_HANDLER"
    type = "S"
  }

  tags = "${merge(var.additional_tags, local.common_tags)}"
}

resource "aws_dynamodb_table" "dynamodb-Event_Name_Dev" {
  name           = "${var.envPrefix}_Event_Name_Dev"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "EVENT_NAME"

  attribute {
    name = "EVENT_NAME"
    type = "S"
  }

  tags = "${merge(var.additional_tags, local.common_tags)}"
}

resource "aws_dynamodb_table" "dynamodb-Event_Name_Stg" {
  name           = "${var.envPrefix}_Event_Name_Stg"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "EVENT_NAME"

  attribute {
    name = "EVENT_NAME"
    type = "S"
  }

  tags = "${merge(var.additional_tags, local.common_tags)}"
}

resource "aws_dynamodb_table" "dynamodb-Event_Name_Prod" {
  name           = "${var.envPrefix}_Event_Name_Prod"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "EVENT_NAME"

  attribute {
    name = "EVENT_NAME"
    type = "S"
  }

  tags = "${merge(var.additional_tags, local.common_tags)}"
}

resource "aws_dynamodb_table" "dynamodb-Event_Status_Dev" {
  name           = "${var.envPrefix}_Event_Status_Dev"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "EVENT_STATUS"

  attribute {
    name = "EVENT_STATUS"
    type = "S"
  }

  tags = "${merge(var.additional_tags, local.common_tags)}"
}

resource "aws_dynamodb_table" "dynamodb-Event_Status_Stg" {
  name           = "${var.envPrefix}_Event_Status_Stg"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "EVENT_STATUS"

  attribute {
    name = "EVENT_STATUS"
    type = "S"
  }

  tags = "${merge(var.additional_tags, local.common_tags)}"
}

resource "aws_dynamodb_table" "dynamodb-Event_Status_Prod" {
  name           = "${var.envPrefix}_Event_Status_Prod"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "EVENT_STATUS"

  attribute {
    name = "EVENT_STATUS"
    type = "S"
  }

  tags = "${merge(var.additional_tags, local.common_tags)}"
}

resource "aws_dynamodb_table" "dynamodb-Event_Type_Dev" {
  name           = "${var.envPrefix}_Event_Type_Dev"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "EVENT_TYPE"

  attribute {
    name = "EVENT_TYPE"
    type = "S"
  }

  tags = "${merge(var.additional_tags, local.common_tags)}"
}

resource "aws_dynamodb_table" "dynamodb-Event_Type_Stg" {
  name           = "${var.envPrefix}_Event_Type_Stg"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "EVENT_TYPE"

  attribute {
    name = "EVENT_TYPE"
    type = "S"
  }

  tags = "${merge(var.additional_tags, local.common_tags)}"
}

resource "aws_dynamodb_table" "dynamodb-Event_Type_Prod" {
  name           = "${var.envPrefix}_Event_Type_Prod"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "EVENT_TYPE"

  attribute {
    name = "EVENT_TYPE"
    type = "S"
  }

  tags = "${merge(var.additional_tags, local.common_tags)}"
}

resource "aws_dynamodb_table" "dynamodb-Events_Dev" {
  name           = "${var.envPrefix}_Events_Dev"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "EVENT_ID"

  attribute {
    name = "EVENT_ID"
    type = "S"
  }

  tags = "${merge(var.additional_tags, local.common_tags)}"

}

resource "aws_dynamodb_table" "dynamodb-Events_Stg" {
  name           = "${var.envPrefix}_Events_Stg"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "EVENT_ID"

  attribute {
    name = "EVENT_ID"
    type = "S"
  }

  tags = "${merge(var.additional_tags, local.common_tags)}"

}

resource "aws_dynamodb_table" "dynamodb-Events_Prod" {
  name           = "${var.envPrefix}_Events_Prod"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "EVENT_ID"

  attribute {
    name = "EVENT_ID"
    type = "S"
  }

  tags = "${merge(var.additional_tags, local.common_tags)}"

}

resource "aws_dynamodb_table" "dynamodb-Environments_Dev" {
  name           = "${var.envPrefix}_Environments_Dev"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "ENVIRONMENT_ID"

  attribute {
    name = "ENVIRONMENT_ID"
    type = "S"
  }

  attribute {
    name = "SERVICE_DOMAIN"
    type = "S"
  }

  attribute {
    name = "SERVICE_NAME"
    type = "S"
  }

  global_secondary_index {
    name               = "EnvironmentsDomainServiceIndex"
    hash_key           = "SERVICE_DOMAIN"
    range_key          = "SERVICE_NAME"
    write_capacity     = 1
    read_capacity      = 1
    projection_type    = "ALL"
  }

  tags = "${merge(var.additional_tags, local.common_tags)}"

}

resource "aws_dynamodb_table" "dynamodb-Environments_Stg" {
  name           = "${var.envPrefix}_Environments_Stg"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "ENVIRONMENT_ID"

  attribute {
    name = "ENVIRONMENT_ID"
    type = "S"
  }

  attribute {
    name = "SERVICE_DOMAIN"
    type = "S"
  }

  attribute {
    name = "SERVICE_NAME"
    type = "S"
  }

  global_secondary_index {
    name               = "EnvironmentsDomainServiceIndex"
    hash_key           = "SERVICE_DOMAIN"
    range_key          = "SERVICE_NAME"
    write_capacity     = 1
    read_capacity      = 1
    projection_type    = "ALL"
  }

  tags = "${merge(var.additional_tags, local.common_tags)}"

}

resource "aws_dynamodb_table" "dynamodb-Environments_Prod" {
  name           = "${var.envPrefix}_Environments_Prod"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "ENVIRONMENT_ID"

  attribute {
    name = "ENVIRONMENT_ID"
    type = "S"
  }

  attribute {
    name = "SERVICE_DOMAIN"
    type = "S"
  }

  attribute {
    name = "SERVICE_NAME"
    type = "S"
  }

  global_secondary_index {
    name               = "EnvironmentsDomainServiceIndex"
    hash_key           = "SERVICE_DOMAIN"
    range_key          = "SERVICE_NAME"
    write_capacity     = 1
    read_capacity      = 1
    projection_type    = "ALL"
  }

  tags = "${merge(var.additional_tags, local.common_tags)}"

}

resource "aws_dynamodb_table" "dynamodb-Deployments_Dev" {
  name           = "${var.envPrefix}_Deployments_Dev"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "DEPLOYMENT_ID"

  attribute {
    name = "DEPLOYMENT_ID"
    type = "S"
  }

  tags = "${merge(var.additional_tags, local.common_tags)}"

}

resource "aws_dynamodb_table" "dynamodb-Deployments_Stg" {
  name           = "${var.envPrefix}_Deployments_Stg"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "DEPLOYMENT_ID"

  attribute {
    name = "DEPLOYMENT_ID"
    type = "S"
  }

  tags = "${merge(var.additional_tags, local.common_tags)}"

}

resource "aws_dynamodb_table" "dynamodb-Deployments_Prod" {
  name           = "${var.envPrefix}_Deployments_Prod"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "DEPLOYMENT_ID"

  attribute {
    name = "DEPLOYMENT_ID"
    type = "S"
  }

  tags = "${merge(var.additional_tags, local.common_tags)}"

}

resource "aws_dynamodb_table" "dynamodb-Assets_Dev" {
  name           = "${var.envPrefix}_Assets_Dev"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "ID"

  attribute {
    name = "ID"
    type = "S"
  }

  attribute {
    name = "DOMAIN"
    type = "S"
  }

  attribute {
    name = "SERVICE"
    type = "S"
  }

  global_secondary_index {
    name               = "AssetsDomainServiceIndex"
    hash_key           = "DOMAIN"
    range_key          = "SERVICE"
    write_capacity     = 1
    read_capacity      = 1
    projection_type    = "ALL"
  }

  tags = "${merge(var.additional_tags, local.common_tags)}"

}

resource "aws_dynamodb_table" "dynamodb-Assets_Stg" {
  name           = "${var.envPrefix}_Assets_Stg"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "ID"

  attribute {
    name = "ID"
    type = "S"
  }

  attribute {
    name = "DOMAIN"
    type = "S"
  }

  attribute {
    name = "SERVICE"
    type = "S"
  }

  global_secondary_index {
    name               = "AssetsDomainServiceIndex"
    hash_key           = "DOMAIN"
    range_key          = "SERVICE"
    write_capacity     = 1
    read_capacity      = 1
    projection_type    = "ALL"
  }

  tags = "${merge(var.additional_tags, local.common_tags)}"

}

resource "aws_dynamodb_table" "dynamodb-Assets_Prod" {
  name           = "${var.envPrefix}_Assets_Prod"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "ID"

  attribute {
    name = "ID"
    type = "S"
  }

  attribute {
    name = "DOMAIN"
    type = "S"
  }

  attribute {
    name = "SERVICE"
    type = "S"
  }

  global_secondary_index {
    name               = "AssetsDomainServiceIndex"
    hash_key           = "DOMAIN"
    range_key          = "SERVICE"
    write_capacity     = 1
    read_capacity      = 1
    projection_type    = "ALL"
  }

  tags = "${merge(var.additional_tags, local.common_tags)}"

}
