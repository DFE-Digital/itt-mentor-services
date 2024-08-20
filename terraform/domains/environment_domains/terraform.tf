terraform {

  required_version = "= 1.6.4"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.116.0"
    }
  }
  backend "azurerm" {
    container_name       = "ittmsdomains-tf"
    resource_group_name  = "s189p01-ittmsdomains-rg"
    storage_account_name = "s189p01ittmsdomainstf"
  }
}

provider "azurerm" {
  features {}

  skip_provider_registration = true
}
