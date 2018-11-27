
# Configure the Azure Provider
########################################
provider "azurerm" {}

provider "azurestack" {
    arm_endpoint    = "${var.arm_endpoint}"
    # make sure to use tenant subscription not admin
    subscription_id = "${var.subscription_id}"
    # Client id is an app registration - with Application ID
    # Use tenant AD
    client_id       = "${var.client_id}"
    client_secret   = "${var.client_secret}"
    # OAUTH 2.0 AUTHORIZATION ENDPOINT which contains a GUID in your Azure Public subscription
    tenant_id       = "${var.tenant_id}"
}

# Create a resource groups for Azure Stack and Azure Public
########################################
resource "azurestack_resource_group" "demo" {
  name     = "${var.azurestack_resource_group_name}"
  location = "${var.azurestack_location}"
}
resource "azurerm_resource_group" "demo" {
  name     = "${var.azurerm_resource_group_name}"
  location = "${var.azurerm_location}"
}

#Create Network Security Groups
########################################
resource "azurestack_network_security_group" "hybridConnectivityNSG" {
  name                = "hybridConnectivityNSG"
  location            = "${azurestack_resource_group.demo.location}"
  resource_group_name = "${azurestack_resource_group.demo.name}"
}
resource "azurerm_network_security_group" "hybridConnectivityNSG" {
  name                = "hybridConnectivityNSG"
  location            = "${azurerm_resource_group.demo.location}"
  resource_group_name = "${azurerm_resource_group.demo.name}"
}
# Create Azure Public virtual networks
########################################
resource "azurerm_virtual_network" "demo" {
  name                = "ApplicationvNet"
  location            = "${azurerm_resource_group.demo.location}"
  resource_group_name = "${azurerm_resource_group.demo.name}"
  address_space       = "${var.azurerm_adress_space}"
}
resource "azurerm_subnet" "ApplicationSubnet" {
  name                 = "ApplicationSubnet"
  resource_group_name  = "${azurerm_resource_group.demo.name}"
  virtual_network_name = "${azurerm_virtual_network.demo.name}"
  address_prefix       = "${var.azurerm_application_subnet}"
}
resource "azurerm_subnet" "GatewaySubnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = "${azurerm_resource_group.demo.name}"
  virtual_network_name = "${azurerm_virtual_network.demo.name}"
  address_prefix       = "${var.azurerm_gateway_subnet}"
}

# Create Azure Stack Virtual Networks
########################################
resource "azurestack_virtual_network" "demo" {
  name                = "ApplicationvNet"
  address_space       = "${var.azurestack_adress_space}"
  location            = "${azurestack_resource_group.demo.location}"
  resource_group_name = "${azurestack_resource_group.demo.name}"
}
resource "azurestack_subnet" "ApplicationSubnet" {
  name                 = "ApplicationSubnet"
  resource_group_name  = "${azurestack_resource_group.demo.name}"
  virtual_network_name = "${azurestack_virtual_network.demo.name}"
  address_prefix       = "${var.azurestack_application_subnet}"
}
resource "azurestack_subnet" "GatewaySubnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = "${azurestack_resource_group.demo.name}"
  virtual_network_name = "${azurestack_virtual_network.demo.name}"
  address_prefix       = "${var.azurestack_gateway_subnet}"
}

#Create public IPs for Azure and Azure Stack - Azure Stack has a static IP
########################################
resource "azurestack_public_ip" "vpnIP" {
  name                         = "vpnIP"
  location                     = "${azurestack_resource_group.demo.location}"
  resource_group_name          = "${azurestack_resource_group.demo.name}"
  public_ip_address_allocation = "Dynamic"
}
resource "azurerm_public_ip" "vpnIP" {
  name                         = "vpnIP"
  location                     = "${azurerm_resource_group.demo.location}"
  resource_group_name          = "${azurerm_resource_group.demo.name}"
  public_ip_address_allocation = "Dynamic"
}

# Get dynamic IP address
########################################
data "azurerm_public_ip" "output" {
  name                = "${azurerm_public_ip.vpnIP.name}"
  resource_group_name = "${azurerm_resource_group.demo.name}"
}

data "azurestack_public_ip" "output" {
  name                = "${azurestack_public_ip.vpnIP.name}"
  resource_group_name = "${azurestack_resource_group.demo.name}"
}

#Create VPN gateways in Azure and Azure Stack
########################################
resource "azurestack_virtual_network_gateway" "demo" {
  depends_on = ["azurestack_subnet.GatewaySubnet"]
  depends_on = ["azurestack_public_ip.vpnIP"]
  name                = "${var.azurestack_virtual_network_gateway_name}"
  location            = "${azurestack_resource_group.demo.location}"
  resource_group_name = "${azurestack_resource_group.demo.name}"
  type                = "Vpn"
  vpn_type            = "RouteBased"
  enable_bgp          = false
  sku                 = "${var.azurestack_vpn_sku}"
  ip_configuration {
    public_ip_address_id          = "${azurestack_public_ip.vpnIP.id}"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = "${azurestack_subnet.GatewaySubnet.id}"
  }
}
resource "azurerm_virtual_network_gateway" "demo" {
  depends_on = ["azurerm_subnet.GatewaySubnet"]
  depends_on = ["azurerm_public_ip.vpnIP"]
  name                = "${var.azurerm_virtual_network_gateway_name}"
  location            = "${azurerm_resource_group.demo.location}"
  resource_group_name = "${azurerm_resource_group.demo.name}"

  type                = "Vpn"
  vpn_type            = "RouteBased"
  sku                 = "${var.azurerm_vpn_sku}"

  ip_configuration {
    public_ip_address_id          = "${azurerm_public_ip.vpnIP.id}"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = "${azurerm_subnet.GatewaySubnet.id}"
  }
}

# Create 'local' network gateways in Azure and Azure Stack
########################################
resource "azurestack_local_network_gateway" "onpremise" {
  depends_on = ["azurestack_virtual_network_gateway.demo"]
  name                = "onpremise"
  location            = "${azurestack_resource_group.demo.location}"
  resource_group_name = "${azurestack_resource_group.demo.name}"
  gateway_address     = "${data.azurerm_public_ip.output.ip_address}"
  address_space       = "${var.azurerm_adress_space}"

}
resource "azurerm_local_network_gateway" "public" {
  depends_on = ["azurerm_virtual_network_gateway.demo"]
  name                = "public"
  location            = "${azurerm_resource_group.demo.location}"
  resource_group_name = "${azurerm_resource_group.demo.name}"
  gateway_address     = "${data.azurestack_public_ip.output.ip_address}"
  address_space       = "${var.azurestack_adress_space}"
  
}

#Create the connection
########################################
resource "azurestack_virtual_network_gateway_connection" "onpremise" {
  depends_on = ["azurestack_local_network_gateway.onpremise"]
  name                = "onpremise"
  location            = "${azurestack_resource_group.demo.location}"
  resource_group_name = "${azurestack_resource_group.demo.name}"

  type = "IPsec"
  virtual_network_gateway_id = "${azurestack_virtual_network_gateway.demo.id}"
  local_network_gateway_id   = "${azurestack_local_network_gateway.onpremise.id}"
  shared_key                 = "${var.shared_key}"

}
resource "azurerm_virtual_network_gateway_connection" "public" {
  depends_on = ["azurerm_local_network_gateway.public"]
  name                = "public"
  location            = "${azurerm_resource_group.demo.location}"
  resource_group_name = "${azurerm_resource_group.demo.name}"
  type = "IPsec"
  virtual_network_gateway_id = "${azurerm_virtual_network_gateway.demo.id}"
  local_network_gateway_id   = "${azurerm_local_network_gateway.public.id}"
  shared_key                 = "${var.shared_key}"

}

#