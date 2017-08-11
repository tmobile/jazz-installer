variable "region" {
  type = "string"
  default = "us-east-1"
}
variable "netVarsfile" {
  type = "string"
  default = "../terraform-unix-demo-jazz/netvars.tf"
}
variable "cidrblocks" {}
