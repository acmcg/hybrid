
# Configure the Azure Provider
provider "azurerm" {}

resource "azurerm_resource_group" "test" {
  name     = "acceptanceTestResourceGroup1"
  location = "West US"
}

resource "azurerm_network_security_group" "test" {
  name                = "acceptanceTestSecurityGroup1"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
}

resource "azurerm_virtual_network" "Azure vNet" {
  name                = "ApplicationvNet"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
  address_space       = ["10.100.102.9/23"]

  subnet {
    name           = "ApplicationSubnet"
    address_prefix = "10.100.102.0/24"
  }
  tags {
    environment = "Production"
  }
}