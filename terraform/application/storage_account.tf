resource "azurerm_storage_account" "general_storage_account" {
  name                             = local.azure_storage_account_name
  resource_group_name              = local.app_resource_group_name
  location                         = "UK South"
  account_tier                     = "Standard"
  account_replication_type         = "LRS"
  allow_nested_items_to_be_public  = false
  cross_tenant_replication_enabled = false

  dynamic "blob_properties" {
    for_each = var.environment == "production" ? [1] : []

    content {
      delete_retention_policy {
        days = 7
      }

      container_delete_retention_policy {
        days = 7
      }
    }
  }

  lifecycle { ignore_changes = [tags] }
}

resource "azurerm_storage_container" "general_container" {
  name                  = "storage"
  storage_account_name  = azurerm_storage_account.general_storage_account.name
  container_access_type = "private"
}
