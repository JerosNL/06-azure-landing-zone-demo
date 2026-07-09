variable "workload" {
  description = "Workload name used in resource naming"
  type        = string
  default     = "vandermeer"
}

variable "environment" {
  description = "Environment name used in resource naming"
  type        = string
  default     = "lab"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "westeurope"
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = string
  default     = "10.0.0.0/16"
}

variable "domain_name" {
  description = "Active Directory domain name"
  type        = string
  default     = "vandermeer.local"
}

variable "admin_username" {
  description = "Local administrator username for VMs"
  type        = string
  default     = "vmadmin"
}

variable "admin_password" {
  description = "Local administrator password for VMs"
  type        = string
  sensitive   = true
}

variable "dc_count" {
  description = "Number of domain controllers to provision"
  type        = number
  default     = 1
}

variable "dc_vm_size" {
  description = "VM size for domain controllers"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "mgmt_vm_size" {
  description = "VM size for management server"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "mgmt_count" {
  description = "Number of management servers to provision"
  type        = number
  default     = 1
}

variable "vpn_root_certificate" {
  description = "Base64 encoded root certificate for VPN point-to-site authentication"
  type        = string
  sensitive   = true
}

variable "vpn_gateway_sku" {
  description = "SKU for the VPN Gateway. Basic supports 10 connections, VpnGw1 supports 250"
  type        = string
  default     = "VpnGw1"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-vandermeer-lab"
}