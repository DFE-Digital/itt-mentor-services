terraform {
  required_version = "= 1.14.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.61.0"
    }
  }
  backend "azurerm" {
    container_name       = "ittmsdomains-tf"
    resource_group_name  = "s189p01-ittmsdomains-rg"
    storage_account_name = "s189p01ittmsdomainstf"
    key                  = "ittmsdomains.tfstate"
  }
}

provider "azurerm" {
  features {}

  resource_provider_registrations = "none"
}
