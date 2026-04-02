#########################
######PUBLIC STORAGE


module "storage_public" {
  source = "./vendor/modules/aks//aks/storage_account"

  name                          = "pub"
  environment                   = var.environment
  azure_resource_prefix         = var.azure_resource_prefix
  service_short                 = var.service_short
  config_short                  = var.config_short
  public_network_access_enabled = true            ##TOGGLE PUB/PRIV
  cluster_configuration_map     = module.cluster_data.configuration_map
  use_private_storage           = false           ##TOGGLE PUB/PRIV

  # Create containers for the application (all containers are private)
  containers = [
    { name = "files" }
  ]

  # Configure blob lifecycle management (default: delete after 7 days)
  container_delete_retention_days = var.storage_container_delete_retention_days
  blob_delete_after_days          = 0

}

#########################
######PRIVATE STORAGE

module "storage_private" {
  source = "./vendor/modules/aks//aks/storage_account"

  name                          = "priv"
  environment                   = var.environment
  azure_resource_prefix         = var.azure_resource_prefix
  service_short                 = var.service_short
  config_short                  = var.config_short
  public_network_access_enabled = false                         ##TOGGLE PUB/PRIV
  cluster_configuration_map     = module.cluster_data.configuration_map
  use_private_storage           = true                          ##TOGGLE PUB/PRIV

  # Create containers for the application (all containers are private)
  containers = [
    { name = "files" }
  ]

  # Configure blob lifecycle management (default: delete after 7 days)
#  container_delete_retention_days = var.storage_container_delete_retention_days
  blob_delete_after_days          = 0

}
