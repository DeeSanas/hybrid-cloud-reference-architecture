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

resource "azurerm_resource_group" "this" {
  name     = "rg-vwan-reference"
  location = "East US"
}

resource "azurerm_virtual_wan" "this" {
  name                = "vwan-enterprise-reference"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  type                = "Standard"
}

resource "azurerm_virtual_hub" "this" {
  name                = "vhub-eastus-reference"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  virtual_wan_id      = azurerm_virtual_wan.this.id
  address_prefix      = "10.100.0.0/23"
}

locals {
  vnets = {
    prod = {
      address_space = ["10.110.0.0/16"]
    }
    shared = {
      address_space = ["10.120.0.0/16"]
    }
  }
}

resource "azurerm_virtual_network" "this" {
  for_each = local.vnets

  name                = "vnet-${each.key}-reference"
  address_space       = each.value.address_space
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_virtual_hub_connection" "this" {
  for_each = local.vnets

  name                      = "conn-${each.key}"
  virtual_hub_id            = azurerm_virtual_hub.this.id
  remote_virtual_network_id = azurerm_virtual_network.this[each.key].id
}

output "virtual_hub_id" {
  value = azurerm_virtual_hub.this.id
}
