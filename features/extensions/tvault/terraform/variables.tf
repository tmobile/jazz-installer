# These variables are set by CLI args from the calling script
variable "region" { type = "string" default = "us-east-2" }
variable "jazz_aws_accountid" {type = "string"}
variable "env_prefix" {type = "string"}
variable "network_range" { type = "string" default = "0.0.0.0/0"}
variable "jenkins_docker_image" {
  type = "string"
  default = "jazzserverless/jazzoss-tvault:latest"
}
variable "ecsJenkinscpu" { type = "string" default = "1024" }
variable "ecsJenkinsmemory" { type = "string" default = "3072" }
variable "existing_vpc_ecs" { type = "string" }
variable "tvault_port1" {type = "string" default = "3000"}
variable "tvault_port2" {type = "string" default = "3001"}
variable "tvault_port3" {type = "string" default = "80"}
variable "tvault_port4" {type = "string" default = "443"}
variable "tvault_port5" {type = "string" default = "8200"}
variable "tvault_port6" {type = "string" default = "8201"}
