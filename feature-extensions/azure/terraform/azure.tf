# Create a role for the Lambda function to exec under

# Create Development Resource group
resource "azurerm_resource_group" "development" {
  name     = "${jazzprefix}-development"
  location = "${var.location}"
}

resource "azurerm_resource_group" "staging" {
  name = "${jazzprefix}-staging"
  location = "${var.location}"
}

resource "azurerm_resource_group" "production" {
  name = "${jazzprefix}-production"
  location = "${var.location}"
}

resource "azurerm_api_management" "development" {
  name                = "${jazzprefix}-dev-apim"
  location            = "${azurerm_resource_group.development.location}"
  resource_group_name = "${azurerm_resource_group.development.name}"
  publisher_name      = "${company_name}"
  publisher_email     = "${company_email}"

  sku {
    name     = "${apim_dev_sku}"
    capacity = 1
  }
}

resource "azurerm_api_management" "staging" {
  name                = "${jazzprefix}-stage-apim"
  location            = "${azurerm_resource_group.staging.location}"
  resource_group_name = "${azurerm_resource_group.staging.name}"
  publisher_name      = "${company_name}"
  publisher_email     = "${company_email}"

  sku {
    name     = "${apim_stage_sku}"
    capacity = 1
  }
}

resource "azurerm_api_management" "production" {
  name                = "${jazzprefix}-prod-apim"
  location            = "${azurerm_resource_group.production.location}"
  resource_group_name = "${azurerm_resource_group.production.name}"
  publisher_name      = "${company_name}"
  publisher_email     = "${company_email}"

  sku {
    name     = "${apim_prod_sku}"
    capacity = 1
  }
}


