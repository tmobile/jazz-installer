# Create a role for the Lambda function to exec under

# Create Development Resource group
resource "azurerm_resource_group" "development" {
  name     = "${var.jazzprefix}-development"
  location = "${var.location}"
}

resource "azurerm_resource_group" "staging" {
  name = "${var.jazzprefix}-staging"
  location = "${var.location}"
}

resource "azurerm_resource_group" "production" {
  name = "${var.jazzprefix}-production"
  location = "${var.location}"
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


