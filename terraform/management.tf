resource "azurerm_network_interface" "mgmt" {
  count               = var.mgmt_count
  name                = "nic-mgmt-${var.environment}-${format("%02d", count.index + 1)}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.management.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.2.${count.index + 4}"
  }

  tags = {
    managed_by = "terraform"
  }
}

resource "azurerm_windows_virtual_machine" "mgmt" {
  count               = var.mgmt_count
  name                = "vm-mgmt-${var.environment}-${format("%02d", count.index + 1)}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  size                = var.mgmt_vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password

  network_interface_ids = [
    azurerm_network_interface.mgmt[count.index].id
  ]

  os_disk {
    name                 = "osdisk-mgmt-${var.environment}-${format("%02d", count.index + 1)}"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }

  tags = {
    role       = "management"
    managed_by = "terraform"
  }
}

resource "azurerm_virtual_machine_extension" "mgmt_dsc" {
  count                      = var.mgmt_count
  name                       = "DSC"
  virtual_machine_id         = azurerm_windows_virtual_machine.mgmt[count.index].id
  publisher                  = "Microsoft.Powershell"
  type                       = "DSC"
  type_handler_version       = "2.77"
  auto_upgrade_minor_version = true

  settings = jsonencode({
    configuration = {
      url      = "https://raw.githubusercontent.com/JerosNL/06-azure-landing-zone-demo/main/dsc/ManagementServer.ps1.zip"
      script   = "ManagementServer.ps1"
      function = "ManagementServer"
    }
  })

  depends_on = [azurerm_windows_virtual_machine.mgmt]

  tags = {
    managed_by = "terraform"
  }
}