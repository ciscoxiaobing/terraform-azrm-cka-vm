provider "azurerm" {
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
  environment     = var.environment
  features {}
}

# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azapi = {
      source = "azure/azapi"
    }
  }
}

provider "azapi" {
  environment = "china"
}
