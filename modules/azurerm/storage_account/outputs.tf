output "name" {
  value = azurerm_storage_account.sa.name
}

output "id" {
  value = azurerm_storage_account.sa.id
}

output primary_access_key {
  value = azurerm_storage_account.sa.primary_access_key
}

output "primary_connection_string" {
  value = azurerm_storage_account.sa.primary_connection_string
}