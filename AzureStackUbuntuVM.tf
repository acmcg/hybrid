# Create a resource groups for Azure Stack 
########################################
resource "azurestack_resource_group" "azurestack_ubuntu" {
  name     = "${var.ubuntu_resource_group_name}"
  location = "${var.azurestack_location}"
}


# Create Azure Stack network resources
########################################
resource "azurestack_public_ip" "azurestack_ubuntu" {
  name                         = "${var.prefix}-pip"
  location                     = "${azurestack_resource_group.azurestack_ubuntu.location}"
  resource_group_name          = "${azurestack_resource_group.azurestack_ubuntu.name}"
  public_ip_address_allocation = "Dynamic"
  idle_timeout_in_minutes      = 30

  tags {
    environment = "demo"
  }
}
resource "azurestack_network_interface" "azurestack_ubuntu" {
  name                = "${var.prefix}-nic"
  location                     = "${azurestack_resource_group.azurestack_ubuntu.location}"
  resource_group_name          = "${azurestack_resource_group.azurestack_ubuntu.name}"

  ip_configuration {
    name                          = "${var.prefix}-ip"
    subnet_id                     = "${azurestack_subnet.ApplicationSubnet.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurestack_public_ip.azurestack_ubuntu.id}"
  }
}
# Create Azure storage Resources
########################################

resource "random_id" "storage_account" {
  byte_length = 4
}
resource "azurestack_storage_account" "azurestack_ubuntu" {
  name                     = "${var.prefix}${lower(random_id.storage_account.hex)}"
  location                 = "${azurestack_resource_group.azurestack_ubuntu.location}"
  resource_group_name      = "${azurestack_resource_group.azurestack_ubuntu.name}"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags {
    environment = "demo"
  }
}
resource "azurestack_storage_container" "azurestack_ubuntu" {
  name                  = "${var.ubuntu_storage_container_name}"
  resource_group_name = "${azurestack_resource_group.azurestack_ubuntu.name}"
  storage_account_name  = "${azurestack_storage_account.azurestack_ubuntu.name}"
  container_access_type = "private"
}
# Create Azure Stack Ubuntu VM
########################################
resource "azurestack_virtual_machine" "azurestack_ubuntu" {
  name                  = "${var.prefix}-vm"
  location              = "${azurestack_resource_group.azurestack_ubuntu.location}"
  resource_group_name   = "${azurestack_resource_group.azurestack_ubuntu.name}"
  network_interface_ids = ["${azurestack_network_interface.azurestack_ubuntu.id}"]
  vm_size               = "${var.ubuntu_vm_size}"

  # The follownig line deletes the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name          = "${var.prefix}${lower(random_id.storage_account.hex)}"
    vhd_uri       = "${azurestack_storage_account.azurestack_ubuntu.primary_blob_endpoint}${azurestack_storage_container.azurestack_ubuntu.name}/myosdisk1.vhd"
    caching       = "ReadWrite"
    create_option = "FromImage"
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
    environment = "S2SVPNdemo"
  }
}