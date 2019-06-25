# These variables are set by CLI args from the calling script
variable "region" { type = "string" default = "us-east-2" }
variable "jazz_aws_accountid" {type = "string"}
variable "env_prefix" {type = "string"}
variable "gateway_func_arn" {type = "string"} # TODO when the terraform import bug is fixed this should be removed.
variable "previous_role_arn" {type = "string"} # TODO when the terraform import bug is fixed this should be removed.
