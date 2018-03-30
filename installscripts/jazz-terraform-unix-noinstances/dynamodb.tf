resource "aws_dynamodb_table" "dynamodb-table-dev" {
  name           = "${var.envPrefix}_services_dev"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "SERVICE_ID"

  attribute {
    name = "SERVICE_ID"
    type = "S"
  }

  tags {
    Name        = "${var.envPrefix}"
    Application = "Jazz"
    JazzInstance = "${var.envPrefix}"
    Environment = "${var.tagsEnvironment}"
    Exempt = "${var.tagsExempt}"
    Owner = "${var.tagsOwner}"
  }
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

  tags {
    Name        = "${var.envPrefix}"
    Application = "Jazz"
    JazzInstance = "${var.envPrefix}"
    Environment = "${var.tagsEnvironment}"
    Exempt = "${var.tagsExempt}"
    Owner = "${var.tagsOwner}"
  }
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

  tags {
    Name        = "${var.envPrefix}"
    Application = "Jazz"
    JazzInstance = "${var.envPrefix}"
    Environment = "${var.tagsEnvironment}"
    Exempt = "${var.tagsExempt}"
    Owner = "${var.tagsOwner}"
  }
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

  tags {
    Name        = "${var.envPrefix}"
    Application = "Jazz"
    JazzInstance = "${var.envPrefix}"
    Environment = "${var.tagsEnvironment}"
    Exempt = "${var.tagsExempt}"
    Owner = "${var.tagsOwner}"
  }

  provisioner "local-exec" {
    command = "${var.dynamodb_cmd} EVENT_HANDLER ${var.envPrefix}_Event_Handler_Dev"
  }
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

  tags {
    Name        = "${var.envPrefix}"
    Application = "Jazz"
    JazzInstance = "${var.envPrefix}"
    Environment = "${var.tagsEnvironment}"
    Exempt = "${var.tagsExempt}"
    Owner = "${var.tagsOwner}"
  }
  provisioner "local-exec" {
    command = "${var.dynamodb_cmd} EVENT_HANDLER ${var.envPrefix}_Event_Handler_Stg"
  }
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

  tags {
    Name        = "${var.envPrefix}"
    Application = "Jazz"
    JazzInstance = "${var.envPrefix}"
    Environment = "${var.tagsEnvironment}"
    Exempt = "${var.tagsExempt}"
    Owner = "${var.tagsOwner}"
  }
  provisioner "local-exec" {
    command = "${var.dynamodb_cmd} EVENT_HANDLER ${var.envPrefix}_Event_Handler_Prod"
  }
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

  tags {
    Name        = "${var.envPrefix}"
    Application = "Jazz"
    JazzInstance = "${var.envPrefix}"
    Environment = "${var.tagsEnvironment}"
    Exempt = "${var.tagsExempt}"
    Owner = "${var.tagsOwner}"

  }
  provisioner "local-exec" {
    command = "${var.dynamodb_cmd} EVENT_NAME ${var.envPrefix}_Event_Name_Dev"
  }
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

  tags {
    Name        = "${var.envPrefix}"
    Application = "Jazz"
    JazzInstance = "${var.envPrefix}"
    Environment = "${var.tagsEnvironment}"
    Exempt = "${var.tagsExempt}"
    Owner = "${var.tagsOwner}"
  }
  provisioner "local-exec" {
    command = "${var.dynamodb_cmd} EVENT_NAME ${var.envPrefix}_Event_Name_Stg"
  }
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

  tags {
    Name        = "${var.envPrefix}"
    Application = "Jazz"
    JazzInstance = "${var.envPrefix}"
    Environment = "${var.tagsEnvironment}"
    Exempt = "${var.tagsExempt}"
    Owner = "${var.tagsOwner}"
  }
  provisioner "local-exec" {
    command = "${var.dynamodb_cmd} EVENT_NAME ${var.envPrefix}_Event_Name_Prod"
  }
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

  tags {
    Name        = "${var.envPrefix}"
    Application = "Jazz"
    JazzInstance = "${var.envPrefix}"
    Environment = "${var.tagsEnvironment}"
    Exempt = "${var.tagsExempt}"
    Owner = "${var.tagsOwner}"
  }
  provisioner "local-exec" {
    command = "${var.dynamodb_cmd} EVENT_STATUS ${var.envPrefix}_Event_Status_Dev"
  }
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

  tags {
    Name        = "${var.envPrefix}"
    Application = "Jazz"
    JazzInstance = "${var.envPrefix}"
    Environment = "${var.tagsEnvironment}"
    Exempt = "${var.tagsExempt}"
    Owner = "${var.tagsOwner}"
  }
  provisioner "local-exec" {
    command = "${var.dynamodb_cmd} EVENT_STATUS ${var.envPrefix}_Event_Status_Stg"
  }
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

  tags {
    Name        = "${var.envPrefix}"
    Application = "Jazz"
    JazzInstance = "${var.envPrefix}"
    Environment = "${var.tagsEnvironment}"
    Exempt = "${var.tagsExempt}"
    Owner = "${var.tagsOwner}"
  }
  provisioner "local-exec" {
    command = "${var.dynamodb_cmd} EVENT_STATUS ${var.envPrefix}_Event_Status_Prod"
  }
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

  tags {
    Name        = "${var.envPrefix}"
    Application = "Jazz"
    JazzInstance = "${var.envPrefix}"
    Environment = "${var.tagsEnvironment}"
    Exempt = "${var.tagsExempt}"
    Owner = "${var.tagsOwner}"
  }
  provisioner "local-exec" {
    command = "${var.dynamodb_cmd} EVENT_TYPE ${var.envPrefix}_Event_Type_Dev"
  }
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

  tags {
    Name        = "${var.envPrefix}"
    Application = "Jazz"
    JazzInstance = "${var.envPrefix}"
    Environment = "${var.tagsEnvironment}"
    Exempt = "${var.tagsExempt}"
    Owner = "${var.tagsOwner}"
  }
  provisioner "local-exec" {
    command = "${var.dynamodb_cmd} EVENT_TYPE ${var.envPrefix}_Event_Type_Stg"
  }
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

  tags {
    Name        = "${var.envPrefix}"
    Application = "Jazz"
    JazzInstance = "${var.envPrefix}"
    Environment = "${var.tagsEnvironment}"
    Exempt = "${var.tagsExempt}"
    Owner = "${var.tagsOwner}"
  }
  provisioner "local-exec" {
    command = "${var.dynamodb_cmd} EVENT_TYPE ${var.envPrefix}_Event_Type_Prod"
  }
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

  tags {
    Name        = "${var.envPrefix}"
    Application = "Jazz"
    JazzInstance = "${var.envPrefix}"
    Environment = "${var.tagsEnvironment}"
    Exempt = "${var.tagsExempt}"
    Owner = "${var.tagsOwner}"
  }
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

  tags {
    Name        = "${var.envPrefix}"
    Application = "Jazz"
    JazzInstance = "${var.envPrefix}"
    Environment = "${var.tagsEnvironment}"
    Exempt = "${var.tagsExempt}"
    Owner = "${var.tagsOwner}"
  }
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

  tags {
    Name        = "${var.envPrefix}"
    Application = "Jazz"
    JazzInstance = "${var.envPrefix}"
    Environment = "${var.tagsEnvironment}"
    Exempt = "${var.tagsExempt}"
    Owner = "${var.tagsOwner}"
  }
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

  tags {
    Name        = "${var.envPrefix}"
    Application = "Jazz"
    JazzInstance = "${var.envPrefix}"
    Environment = "${var.tagsEnvironment}"
    Exempt = "${var.tagsExempt}"
    Owner = "${var.tagsOwner}"
  }
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

  tags {
    Name        = "${var.envPrefix}"
    Application = "Jazz"
    JazzInstance = "${var.envPrefix}"
    Environment = "${var.tagsEnvironment}"
    Exempt = "${var.tagsExempt}"
    Owner = "${var.tagsOwner}"
  }
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

  tags {
    Name        = "${var.envPrefix}"
    Application = "Jazz"
    JazzInstance = "${var.envPrefix}"
    Environment = "${var.tagsEnvironment}"
    Exempt = "${var.tagsExempt}"
    Owner = "${var.tagsOwner}"
  }
}