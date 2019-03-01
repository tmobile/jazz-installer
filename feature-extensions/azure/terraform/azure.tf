resource "azurerm_resource_group" "development" {
  name     = "${var.jazzprefix}-development"
  location = "${var.location}"
}

output "dev_resource_group" {
  value = "${azurerm_resource_group.development.name}"
}

resource "azurerm_resource_group" "staging" {
  name = "${var.jazzprefix}-staging"
  location = "${var.location}"
}

output "stage_resource_group" {
  value = "${azurerm_resource_group.staging.name}"
}

resource "azurerm_resource_group" "production" {
  name      = "${var.jazzprefix}-production"
  location  = "${var.location}"
}

output "prod_resource_group" {
  value = "${azurerm_resource_group.production.name}"
}

resource "azurerm_api_management" "development" {
  name                = "${var.jazzprefix}-dev-apim"
  location            = "${azurerm_resource_group.development.location}"
  resource_group_name = "${azurerm_resource_group.development.name}"
  publisher_name      = "${var.company_name}"
  publisher_email     = "${var.company_email}"

  sku {
    name     = "${var.apim_dev_sku}"
    capacity = 1
  }
}

output "dev_apim" {
  value = "${azurerm_api_management.development.name}"
}

resource "azurerm_api_management" "staging" {
  name                = "${var.jazzprefix}-stage-apim"
  location            = "${azurerm_resource_group.staging.location}"
  resource_group_name = "${azurerm_resource_group.staging.name}"
  publisher_name      = "${var.company_name}"
  publisher_email     = "${var.company_email}"

  sku {
    name     = "${var.apim_stage_sku}"
    capacity = 1
  }
}

output "stage_apim" {
  value = "${azurerm_api_management.staging.name}"
}

resource "azurerm_api_management" "production" {
  name                = "${var.jazzprefix}-prod-apim"
  location            = "${azurerm_resource_group.production.location}"
  resource_group_name = "${azurerm_resource_group.production.name}"
  publisher_name      = "${var.company_name}"
  publisher_email     = "${var.company_email}"

  sku {
    name     = "${var.apim_prod_sku}"
    capacity = 1
  }
}

output "prod_apim" {
  value = "${azurerm_api_management.production.name}"
}


resource "azurerm_eventhub_namespace" "production" {
  name = "${var.jazzprefix}-eventhub-ns"
  location = "${azurerm_resource_group.production.location}"
  resource_group_name = "${azurerm_resource_group.production.name}"
  sku = "Basic"
  capacity = 1
  kafka_enabled = false

  tags {
    environment = "Production"
  }
}

resource "azurerm_eventhub" "production" {
  name = "${var.jazzprefix}-eventhub"
  namespace_name = "${azurerm_eventhub_namespace.production.name}"
  resource_group_name = "${azurerm_resource_group.production.name}"
  partition_count = 2
  message_retention = 1
}
