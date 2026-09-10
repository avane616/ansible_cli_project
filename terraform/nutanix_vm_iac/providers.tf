provider "nutanix" {
  endpoint = "10.45.203.90"
  username = "Automation"
  password = var.prism
  insecure = true
}

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
