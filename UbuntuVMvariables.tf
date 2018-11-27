
 # Resource Group Names
    ###############################################################
variable "ubuntu_resource_group_name" {
        default = "ubuntuVM"
}
variable "prefix" {
  default = "ubuntu"
}

variable "ubuntu_storage_container_name" {
  default = "vhds"
}
variable "ubuntu_vm_size" {
  default = "Standard_DS1_v2"
}
variable "ubuntu_computer_name" {
  default = "ubuntu"
}
variable "ubuntu_admin_username" {
  default = "tempadmin"
}
variable "ubuntu_admin_password" {}


