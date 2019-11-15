# These variables are set by CLI args from the calling script
variable "region" { type = "string" default = "us-east-2" }
variable "envPrefix" {type = "string"}
variable "network_range" { type = "string" default = "0.0.0.0/0"}
variable "tvault_docker_image" {
  type = "string"
  default = "jazzserverless/jazzoss-tvault:1.0.0"
}
variable "ecsTvaultcpu" { type = "string" default = "2048" }
variable "ecsTvaultmemory" { type = "string" default = "4096" }
variable "tvault_port1" {type = "string" default = "3000"}
variable "tvault_port2" {type = "string" default = "80"}
variable "tvault_port3" {type = "string" default = "8200"}
variable "jazzPassword" {type = "string"}
variable "jazzUsername" {type = "string"}
variable "ecsConsulcpu" { type = "string" default = "512" }
variable "ecsConsulmemory" { type = "string" default = "1024" }
variable "consul_docker_image" {
  type = "string"
  default = "consul:latest"
}
variable "consul_port1" {type = "string" default = "8500"}
variable "consul_port2" {type = "string" default = "8502"}
variable "consul_port3" {type = "string" default = "8300"}
variable "consul_port4" {type = "string" default = "8301"}
variable "consul_port5" {type = "string" default = "8400"}
variable "consul_port6" {type = "string" default = "8600"}
variable "consul_port7" {type = "string" default = "8302"}
variable "consul_port8" {type = "string" default = "80"}
