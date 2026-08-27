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
  type    = string
  default = "East US"
}

resource "azurerm_resource_group" "landing_zone" {
  name     = "rg-landing-zone-lab"
  location = var.location

  tags = {
    Environment = "landing-zone-lab"
    ManagedBy   = "terraform"
  }
}

resource "azurerm_virtual_network" "hub" {
  name                = "vnet-hub"
  location            = azurerm_resource_group.landing_zone.location
  resource_group_name = azurerm_resource_group.landing_zone.name
  address_space       = ["10.50.0.0/16"]
}

resource "azurerm_subnet" "shared" {
  name                 = "snet-shared-services"
  resource_group_name  = azurerm_resource_group.landing_zone.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.50.10.0/24"]
}

resource "azurerm_virtual_network" "app" {
  name                = "vnet-app-prod"
  location            = azurerm_resource_group.landing_zone.location
  resource_group_name = azurerm_resource_group.landing_zone.name
  address_space       = ["10.51.0.0/16"]
}

resource "azurerm_subnet" "app" {
  name                 = "snet-app"
  resource_group_name  = azurerm_resource_group.landing_zone.name
  virtual_network_name = azurerm_virtual_network.app.name
  address_prefixes     = ["10.51.10.0/24"]
}

resource "azurerm_virtual_network_peering" "hub_to_app" {
  name                      = "peer-hub-to-app"
  resource_group_name       = azurerm_resource_group.landing_zone.name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.app.id
}

resource "azurerm_virtual_network_peering" "app_to_hub" {
  name                      = "peer-app-to-hub"
  resource_group_name       = azurerm_resource_group.landing_zone.name
  virtual_network_name      = azurerm_virtual_network.app.name
  remote_virtual_network_id = azurerm_virtual_network.hub.id
}

output "hub_vnet_id" {
  value = azurerm_virtual_network.hub.id
}

output "application_vnet_id" {
  value = azurerm_virtual_network.app.id
}
