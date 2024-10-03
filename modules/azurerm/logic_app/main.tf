resource "azurerm_logic_app_standard" "app" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  storage_account_name       = module.logic_app_sa.name
  storage_account_access_key = module.logic_app_sa.primary_access_key
  storage_account_share_name = "default"
  app_service_plan_id        = var.app_service_plan_id

  identity {
    type = "SystemAssigned"
  }

  virtual_network_subnet_id = var.logic_app_subnet_id

  app_settings = merge(
    {
      "FUNCTIONS_EXTENSION_VERSION" = "~3"
      "FUNCTIONS_WORKER_RUNTIME" = "node"
      "APPINSIGHTS_INSTRUMENTATIONKEY" = module.logic_app_ai.instrumentation_key
      "APPLICATIONINSIGHTS_CONNECTION_STRING" = module.logic_app_ai.application_insights_connection_string
      "AzureWebJobsStorage" = module.logic_app_sa.primary_connection_string
      "WEBSITE_CONTENTAZUREFILECONNECTIONSTRING" = module.logic_app_sa.primary_connection_string
      "WEBSITE_CONTENTSHARE" = "logic-app-dev-la-content"
      "APP_KIND" = "workflowApp"
      "WEBSITE_VNET_ROUTE_ALL" = 1
      "AzureFunctionsJobHost__extensionBundle__id" = "Microsoft.Azure.Functions.ExtensionBundle.Workflows"
      "AzureFunctionsJobHost__extensionBundle__version": "[1.*, 2.0.0)"
      "WEBSITE_CONTENTOVERVNET": 1
    },
    var.app_settings
  )

  site_config {
    always_on                     = true
    vnet_route_all_enabled        = true
    public_network_access_enabled = false
  }
}

module "logic_app_sa" {
  source = "../storage_account"

  name                       = "${var.name}sa"
  resource_group_name        = var.resource_group_name
  location                   = var.location
  account_tier               = "Standard"
  private_endpoint_subnet_id = var.private_endpoint_subnet_id
  blob_private_dns_zone_id   = var.blob_private_dns_zone_id
  file_private_dns_zone_id   = var.file_private_dns_zone_id
  queue_private_dns_zone_id  = var.queue_private_dns_zone_id
  table_private_dns_zone_id  = var.table_private_dns_zone_id
}

# resource "azurerm_storage_share" "share" {
#   name                 = "${var.name}-share"
#   storage_account_name = module.logic_app_sa.name
#   quota                = 50
# }

module "logic_app_ai" {
  source = "../application_insights"

  name                = "${var.name}-ai"
  resource_group_name = var.resource_group_name
  location            = var.location
}

resource "azurerm_private_endpoint" "pe_logic_app" {
  name                = "${azurerm_logic_app_standard.app.name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${azurerm_logic_app_standard.app.name}-pe"
    private_connection_resource_id = azurerm_logic_app_standard.app.id
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "${azurerm_logic_app_standard.app.name}-dns-group"
    private_dns_zone_ids = [var.logic_app_private_dns_zone_id]
  }
}

module "diagnostic_settings" {
  source = "../monitor_diagnostic_setting"

  name                       = "${var.name}-diag"
  resource_id                = azurerm_logic_app_standard.app.id
  log_analytics_workspace_id = var.log_analytics_workspace_id
}
