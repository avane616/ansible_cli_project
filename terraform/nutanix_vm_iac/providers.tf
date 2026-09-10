provider "nutanix" {}

terraform {
    required_providers {
        nutanix = {
        source  = "nutanix/nutanix"
        version = ">= 2.0.0"
        }
    }
}


provider "azurerm" {
  features {}
}
