    # Azure resource provider variables
    ###############################################################
    variable "arm_endpoint" {
        default  = "https://management.equinix.vigilant.it"
    }
    # make sure to use tenant subscription not admin
    variable "subscription_id" {
         default = "d0153df1-d08e-45b5-ab6b-32c449194267"
    }
    # Client id is an app registration - with Application ID
    # Use tenant AD
    variable "client_id" {
        default  = "4b6d63d2-30e2-4762-84ca-9c237c67a199"
    }
       variable "client_secret" {}
        # OAUTH 2.0 AUTHORIZATION ENDPOINT which contains a GUID in your Azure Public subscription
    variable "tenant_id" {
        default = "62574f56-4554-49e3-9194-34570282a2e3"
    }

    # Shared secret
    ###############################################################
       variable "shared_key" {}
      
   # Resource Group Names
    ###############################################################
      variable "azurestack_resource_group_name" {
        default = "hybridConnectivity"
    }
      variable "azurerm_resource_group_name" {
        default = "hybridConnectivity"
    }
    # AzureRM network variables
    ###############################################################
    variable "azurerm_location" {
        default = "West US"
    }
    variable "azurerm_adress_space" {
        default = ["10.100.102.0/23"]
    }
    variable "azurerm_application_subnet" {
        default = "10.100.102.0/24"
    }
      variable "azurerm_gateway_subnet" {
        default = "10.100.103.0/24"
    }
        variable "azurerm_vpn_sku" {
        default = "basic"
    }
    variable "azurerm_virtual_network_gateway_name" {
        default = "azureVPN"
    }

    # AzureStack network variables
    ###############################################################
    variable "azurestack_location" {
        default = "equinix"
    }
        variable "azurestack_adress_space" {
        default = ["10.100.100.0/23"]
    }
    variable "azurestack_application_subnet" {
        default = "10.100.100.0/24"
    }
      variable "azurestack_gateway_subnet" {
        default = "10.100.101.0/24"
    }
    variable "azurestack_vpn_sku" {
        default = "basic"
    }
    variable "azurestack_virtual_network_gateway_name" {
        default = "azureStackVPN"
    }