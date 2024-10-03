output "instrumentation_key" {
  value = azurerm_application_insights.insights.instrumentation_key
}

output "application_insights_connection_string" {
  value = azurerm_application_insights.insights.connection_string
}