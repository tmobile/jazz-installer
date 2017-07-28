variable "region" {
  type = "string"
  default = "us-east-1"
}
variable "envPrefix" {
  type = "string"
  default = "jazz60"
}
variable "netVarsfile" {
  type = "string"
  default = "../terraform-unix-demo-jazz/netvars.tf"
}
