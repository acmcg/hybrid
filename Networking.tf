
# Configure the Azure Provider
provider "azurerm" {}

resource "azurerm_resource_group" "demo" {
  name     = "hybridConnectivity"
  location = "West US"
}

resource "azurerm_network_security_group" "demo" {
  name                = "hybridConnectivityNSG"
  location            = "${azurerm_resource_group.demo.location}"
  resource_group_name = "${azurerm_resource_group.demo.name}"
}

resource "azurerm_virtual_network" "Azure_vNet" {
  name                = "ApplicationvNet"
  location            = "${azurerm_resource_group.demo.location}"
  resource_group_name = "${azurerm_resource_group.demo.name}"
  address_space       = ["10.100.102.9/23"]

  subnet {
    name           = "ApplicationSubnet"
    address_prefix = "10.100.102.0/24"
  }
  tags {
    environment = "Demonstration"
  }
}