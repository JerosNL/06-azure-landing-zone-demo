resource "azurerm_public_ip" "vpn_gateway" {
  name                = "pip-vpng-${var.environment}-01"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]

  tags = {
    managed_by = "terraform"
  }
}

resource "azurerm_virtual_network_gateway" "main" {
  name                = "vpng-${var.workload}-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  type                = "Vpn"
  vpn_type            = "RouteBased"
  sku                 = var.vpn_gateway_sku
  active_active       = false
  enable_bgp          = false

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.vpn_gateway.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gateway.id
  }

  vpn_client_configuration {
    address_space = ["172.16.0.0/24"]

    vpn_client_protocols = ["OpenVPN"]

    root_certificate {
      name = "VanderMeerRootCert"
      public_cert_data = var.vpn_root_certificate
    }
  }

  tags = {
    managed_by = "terraform"
  }
}