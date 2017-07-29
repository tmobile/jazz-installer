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
    Application = "${var.tagsApplication}"
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
    Application = "${var.tagsApplication}"
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
    Application = "${var.tagsApplication}"
    Environment = "${var.tagsEnvironment}"
    Exempt = "${var.tagsExempt}"
    Owner = "${var.tagsOwner}"
  }
}

