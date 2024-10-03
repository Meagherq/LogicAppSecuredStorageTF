resource "azurerm_subnet" "subnet" {
  name                 = var.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = var.address_prefixes

  dynamic "delegation" {
    for_each = var.delegations

    content {
      name = delegation.key
      service_delegation {
        name = delegation.value.name
        actions = delegation.value.actions
      }
    }
  }
}