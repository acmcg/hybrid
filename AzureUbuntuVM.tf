# Create a resource groups for Azure Stack 
########################################
resource "azurerm_resource_group" "azurerm_ubuntu" {
  name     = "${var.ubuntu_resource_group_name}"
  location = "${var.azurerm_location}"
}

resource "azurerm_network_interface" "azurerm_ubuntu" {
  name                = "${var.prefix}-nic"
  location            = "${azurerm_resource_group.azurerm_ubuntu.location}"
  resource_group_name = "${azurerm_resource_group.azurerm_ubuntu.name}"

  ip_configuration {
    name                          = "${var.prefix}-ip"
    subnet_id                     = "${azurerm_subnet.ApplicationSubnet.id}"
    private_ip_address_allocation = "dynamic"
  }
}

resource "azurerm_virtual_machine" "azurerm_ubuntu" {
  name                  = "${var.prefix}-vm"
  location              = "${azurerm_resource_group.azurerm_ubuntu.location}"
  resource_group_name   = "${azurerm_resource_group.azurerm_ubuntu.name}"
  network_interface_ids = ["${azurerm_network_interface.azurerm_ubuntu.id}"]
  vm_size               = "${var.ubuntu_vm_size}"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true


  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "${var.prefix}${lower(random_id.storage_account.hex)}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "${var.ubuntu_computer_name}"
    admin_username = "${var.ubuntu_admin_username}"
    admin_password = "${var.ubuntu_admin_password}"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags {
    environment = "demo"
  }
}

