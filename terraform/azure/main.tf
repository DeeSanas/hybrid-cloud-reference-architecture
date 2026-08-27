terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

variable "location" {
  description = "Azure region used by this reference example."
  type        = string
  default     = "eastus"
}

variable "hub_cidr" {
  description = "Non-overlapping CIDR allocated from the enterprise IP plan."
  type        = string
  default     = "10.50.0.0/16"
}

locals {
  tags = {
    environment = "reference"
    managed_by  = "terraform"
    purpose     = "hybrid-cloud-reference"
  }
}

resource "azurerm_resource_group" "hub" {
  name     = "rg-hybrid-hub-reference"
  location = var.location
  tags     = local.tags
}

resource "azurerm_virtual_network" "hub" {
  name                = "vnet-hybrid-hub-reference"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  address_space       = [var.hub_cidr]
  tags                = local.tags
}

resource "azurerm_subnet" "shared" {
  name                 = "snet-shared-services"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [cidrsubnet(var.hub_cidr, 8, 10)]
}

resource "azurerm_network_security_group" "shared" {
  name                = "nsg-shared-services-reference"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  tags                = local.tags
}

resource "azurerm_subnet_network_security_group_association" "shared" {
  subnet_id                 = azurerm_subnet.shared.id
  network_security_group_id = azurerm_network_security_group.shared.id
}

output "hub_vnet_id" {
  value       = azurerm_virtual_network.hub.id
  description = "Hub virtual network identifier."
}
