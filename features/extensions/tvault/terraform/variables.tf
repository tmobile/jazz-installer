# These variables are set by CLI args from the calling script
variable "region" { type = "string" default = "us-east-2" }
variable "envPrefix" {type = "string"}
variable "network_range" { type = "string" default = "0.0.0.0/0"}
variable "tvault_docker_image" {
  type = "string"
  default = "jazzserverless/jazzoss-tvault:latest"
}
variable "ecsTvaultcpu" { type = "string" default = "2048" }
variable "ecsTvaultmemory" { type = "string" default = "4096" }
variable "existing_vpc_ecs" { type = "string" }
variable "tvault_port1" {type = "string" default = "3000"}
variable "tvault_port2" {type = "string" default = "3001"}
variable "tvault_port3" {type = "string" default = "80"}
variable "tvault_port4" {type = "string" default = "443"}
variable "tvault_port5" {type = "string" default = "8200"}
variable "tvault_port6" {type = "string" default = "8201"}
variable "jazzPassword" {type = "string"}
