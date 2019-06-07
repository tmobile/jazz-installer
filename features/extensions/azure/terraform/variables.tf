# These variables are set by CLI args from the calling script
variable "location" { type = "string" }
variable "jazzprefix" {type = "string"}
variable "subscription_id" { type = "string"}
variable "client_id" {type = "string"}
variable "client_secret" {type = "string"}
variable "tenant_id" {type = "string"}
variable "company_name" {type = "string"}
variable "company_email" {type = "string"}
variable "apim_dev_sku" {type = "string" default = "Developer"}
variable "apim_stage_sku" {type = "string" default = "Developer"}
variable "apim_prod_sku" {type = "string" default = "Developer"}

