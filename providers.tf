terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      
    }
    azapi = {
      source = "azure/azapi"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  storage_use_azuread = true
}

provider "azapi" {
  subscription_id = var.subscription_id
}