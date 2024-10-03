terraform {
  required_version = ">=1.2"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.108.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "=2.51.0"
    }
  }
}

provider "azurerm" {
  features {
  }
}

module "resource_group" {
  source   = "../../modules/azurerm/resource_group"
  name     = "${var.workload_prefix}-${var.environment}"
  location = "canadacentral"
}

module "log_analytics_workspace" {
  source              = "../../modules/azurerm/log_analytics_workspace"
  name                = "${var.workload_prefix}-${var.environment}-law"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  retention_in_days   = 365
}

module "virtual_network" {
  source              = "../../modules/azurerm/virtual_network"
  name                = "${var.workload_prefix}-${var.environment}-vnet"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location

  address_space = ["10.0.0.0/16"]

  log_analytics_workspace_id = module.log_analytics_workspace.id
}

module "private_endpoint_subnet" {
  source               = "../../modules/azurerm/virtual_network_subnet"
  name                 = "pe-sn"
  resource_group_name  = module.resource_group.name
  virtual_network_name = module.virtual_network.name
  address_prefixes     = ["10.0.0.0/24"]
}

module "app_subnet" {
  source               = "../../modules/azurerm/virtual_network_subnet"
  name                 = "app-sn"
  resource_group_name  = module.resource_group.name
  virtual_network_name = module.virtual_network.name
  address_prefixes     = ["10.0.1.0/24"]

  delegations = {
    "webapp" = {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

module "logic_app_private_dns_zone" {
  source              = "../../modules/azurerm/private_dns_zone"
  name                = "privatelink.azurewebsites.net"
  resource_group_name = module.resource_group.name
  virtual_network_link_name = "${module.virtual_network.name}-la-link"
  virtual_network_id  = module.virtual_network.id
}

module "blob_private_dns_zone" {
  source              = "../../modules/azurerm/private_dns_zone"
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = module.resource_group.name
  virtual_network_link_name = "${module.virtual_network.name}-blob-link"
  virtual_network_id  = module.virtual_network.id
}

module "file_private_dns_zone" {
  source = "../../modules/azurerm/private_dns_zone"

  name                = "privatelink.file.core.windows.net"
  resource_group_name = module.resource_group.name
  virtual_network_link_name = "${module.virtual_network.name}-file-link"
  virtual_network_id  = module.virtual_network.id
}

module "queue_private_dns_zone" {
  source              = "../../modules/azurerm/private_dns_zone"
  name                = "privatelink.queue.core.windows.net"
  resource_group_name = module.resource_group.name
  virtual_network_link_name = "${module.virtual_network.name}-queue-link"
  virtual_network_id  = module.virtual_network.id
}

module "table_private_dns_zone" {
  source              = "../../modules/azurerm/private_dns_zone"
  name                = "privatelink.table.core.windows.net"
  resource_group_name = module.resource_group.name
  virtual_network_link_name = "${module.virtual_network.name}-table-link"
  virtual_network_id  = module.virtual_network.id
}

module "app_service_plan" {
  source              = "../../modules/azurerm/app_service_plan"
  name                = "${var.workload_prefix}-${var.environment}-asp"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  sku                 = "WS1"
  os_type             = "Linux"
}

module "logic_app" {
  source              = "../../modules/azurerm/logic_app"
  name                = "${var.workload_prefix}-${var.environment}-la"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  app_service_plan_id = module.app_service_plan.id

  app_settings = {}

  logic_app_subnet_id        = module.app_subnet.id
  private_endpoint_subnet_id = module.private_endpoint_subnet.id

  logic_app_private_dns_zone_id = module.logic_app_private_dns_zone.id
  blob_private_dns_zone_id      = module.blob_private_dns_zone.id
  file_private_dns_zone_id      = module.file_private_dns_zone.id
  queue_private_dns_zone_id     = module.queue_private_dns_zone.id
  table_private_dns_zone_id     = module.table_private_dns_zone.id

  log_analytics_workspace_id = module.log_analytics_workspace.id
}
