#Terraform script to deploy resource group, virtual network, and Windows server 2016 virtual machine

provider "azurerm" {
  subscription_id = "xxxx"
  version         = "=2.35.0"
  features {} 
}


resource "azurerm_resource_group" "RG" {
  name     = "resourcegrouptest"
  location = "eastus"
}


resource "azurerm_availability_set" "avail_set" {
  name                = "availa-set"
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name

}


resource "azurerm_virtual_network" "vnet" {
  name                = "vNet_terraform"
  address_space       = ["10.10.1.0/24"]
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name
}


resource "azurerm_subnet" "subnet" {
  name                 = "subnet_internal"
  resource_group_name  = azurerm_resource_group.RG.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes       = ["10.10.1.0/24"]
}


resource "azurerm_network_interface" "iface" {
  name = "nic-iface"
  location = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name

  ip_configuration {
    name                          = "iface"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}


resource "azurerm_windows_virtual_machine" "VM" {
  name                = "vm1"
  resource_group_name = azurerm_resource_group.RG.name
  location            = azurerm_resource_group.RG.location
  size                = "Standard_B1s"
  admin_username      = "adminadmin"
  admin_password      = "thisisbadpassw0rd!"
  availability_set_id = azurerm_availability_set.avail_set.id
  network_interface_ids = [azurerm_network_interface.iface.id]

  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}

