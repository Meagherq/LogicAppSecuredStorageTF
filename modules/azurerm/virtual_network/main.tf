resource "azurerm_virtual_network" "vnet" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space

  tags = var.tags
}

module "diagnostic_settings" {
  source = "../monitor_diagnostic_setting"

  name = "${var.name}-diag"
  resource_id = azurerm_virtual_network.vnet.id
  log_analytics_workspace_id = var.log_analytics_workspace_id
}