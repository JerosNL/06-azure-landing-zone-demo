resource "azurerm_network_interface" "dc" {
  count               = var.dc_count
  name                = "nic-dc-${var.environment}-${format("%02d", count.index + 1)}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.identity.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.${count.index + 4}"
  }

  tags = {
    managed_by = "terraform"
  }
}

resource "azurerm_windows_virtual_machine" "dc" {
  count               = var.dc_count
  name                = "vm-dc-${var.environment}-${format("%02d", count.index + 1)}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  size                = var.dc_vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password

  network_interface_ids = [
    azurerm_network_interface.dc[count.index].id
  ]

  os_disk {
    name                 = "osdisk-dc-${var.environment}-${format("%02d", count.index + 1)}"
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
    role       = "domain-controller"
    managed_by = "terraform"
  }
}

resource "azurerm_virtual_machine_extension" "dc_dsc" {
  count                      = var.dc_count
  name                       = "DSC"
  virtual_machine_id         = azurerm_windows_virtual_machine.dc[count.index].id
  publisher                  = "Microsoft.Powershell"
  type                       = "DSC"
  type_handler_version       = "2.77"
  auto_upgrade_minor_version = true

  settings = jsonencode({
    configuration = {
      url      = "https://raw.githubusercontent.com/JerosNL/06-azure-landing-zone-demo/main/dsc/DomainController.ps1.zip"
      script   = "DomainController.ps1"
      function = "DomainController"
    }
    configurationArguments = {
      DomainName = var.domain_name
    }
  })

  protected_settings = jsonencode({
    configurationArguments = {
      AdminCredential = {
        userName = var.admin_username
        password = var.admin_password
      }
    }
  })

  depends_on = [azurerm_windows_virtual_machine.dc]

  tags = {
    managed_by = "terraform"
  }
}