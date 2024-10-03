resource "azurerm_storage_account" "sa" {
  name                = replace(var.name, "-", "")
  resource_group_name = var.resource_group_name

  public_network_access_enabled = true

  location                 = var.location
  account_tier             = var.account_tier
  account_replication_type = "GRS"

  shared_access_key_enabled = true

  tags = var.tags
}

resource "azurerm_private_endpoint" "pe_blob" {
  name                = "${azurerm_storage_account.sa.name}-pe-blob"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${azurerm_storage_account.sa.name}-pe-sc-sa-blob"
    private_connection_resource_id = azurerm_storage_account.sa.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "${azurerm_storage_account.sa.name}-dns-group-sa-blob"
    private_dns_zone_ids = [var.blob_private_dns_zone_id]
  }
}

# resource "azurerm_private_dns_a_record" "dns_a_sa_blob" {
#   name                = "${azurerm_storage_account.sa.name}-sa-blob-a-record"
#   zone_name           = var.blob_private_dns_zone_name
#   resource_group_name = var.resource_group_name
#   ttl                 = 300
#   records             = [azurerm_private_endpoint.pe_blob.private_service_connection.0.private_ip_address]
# }

resource "azurerm_private_endpoint" "pe_file" {
  name                = "${azurerm_storage_account.sa.name}-pe-file"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${azurerm_storage_account.sa.name}-pe-sc-sa-file"
    private_connection_resource_id = azurerm_storage_account.sa.id
    subresource_names              = ["file"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "${azurerm_storage_account.sa.name}-dns-group-sa-file"
    private_dns_zone_ids = [var.file_private_dns_zone_id]
  }
}

# resource "azurerm_private_dns_a_record" "dns_a_sa_file" {
#   name                = "${azurerm_storage_account.sa.name}-sa-file-a-record"
#   zone_name           = var.file_private_dns_zone_name
#   resource_group_name = var.resource_group_name
#   ttl                 = 300
#   records             = [azurerm_private_endpoint.pe_file.private_service_connection.0.private_ip_address]
# }

resource "azurerm_private_endpoint" "pe_queue" {
  name                = "${azurerm_storage_account.sa.name}-pe-queue"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${azurerm_storage_account.sa.name}-pe-sc-sa-queue"
    private_connection_resource_id = azurerm_storage_account.sa.id
    subresource_names              = ["queue"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "${azurerm_storage_account.sa.name}-dns-group-sa-queue"
    private_dns_zone_ids = [var.queue_private_dns_zone_id]
  }
}

# resource "azurerm_private_dns_a_record" "dns_a_sa_queue" {
#   name                = "${azurerm_storage_account.sa.name}-sa-queue-a-record"
#   zone_name           = var.queue_private_dns_zone_name
#   resource_group_name = var.resource_group_name
#   ttl                 = 300
#   records             = [azurerm_private_endpoint.pe_queue.private_service_connection.0.private_ip_address]
# }

resource "azurerm_private_endpoint" "pe_table" {
  name                = "${azurerm_storage_account.sa.name}-pe-table"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${azurerm_storage_account.sa.name}-pe-sc-sa-table"
    private_connection_resource_id = azurerm_storage_account.sa.id
    subresource_names              = ["table"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "${azurerm_storage_account.sa.name}-dns-group-sa-table"
    private_dns_zone_ids = [var.table_private_dns_zone_id]
  }
}

# resource "azurerm_private_dns_a_record" "dns_a_sa_table" {
#   name                = "${azurerm_storage_account.sa.name}-sa-table-a-record"
#   zone_name           = var.table_private_dns_zone_name
#   resource_group_name = var.resource_group_name
#   ttl                 = 300
#   records             = [azurerm_private_endpoint.pe_table.private_service_connection.0.private_ip_address]
# }