variable "cluster" {
  description = "AKS cluster where this app is deployed. Either 'test' or 'production'"
}
variable "namespace" {
  description = "AKS namespace where this app is deployed"
}
variable "environment" {
  description = "Name of the deployed environment in AKS"
}
variable "azure_resource_prefix" {
  description = "Standard resource prefix. Usually s189t01 (test) or s189p01 (production)"
}
variable "config" {
  description = "The application configuration - should match the tfvars file name e.g. review, production..."
}
variable "config_short" {
  description = "Short name of the environment configuration, e.g. dv, st, pd..."
}
variable "service_name" {
  description = "Full name of the service. Lowercase and hyphen separated"
}
variable "service_short" {
  description = "Short name to identify the service. Up to 6 charcters."
}
variable "deploy_azure_backing_services" {
  default     = true
  description = "Deploy real Azure backing services like databases, as opposed to containers inside of AKS"
}
variable "enable_postgres_ssl" {
  default     = true
  description = "Enforce SSL connection from the client side"
}
variable "enable_postgres_backup_storage" {
  default     = false
  description = "Create a storage account to store database dumps"
}
variable "docker_image" {
  description = "Docker image full name to identify it in the registry. Includes docker registry, repository and tag e.g.: ghcr.io/dfe-digital/teacher-pay-calculator:673f6309fd0c907014f44d6732496ecd92a2bcd0"
}
variable "enable_monitoring" {
  default     = false
  description = "Enable monitoring and alerting"
}
variable "app_replicas" {
  description = "number of replicas of the web app"
  default     = 1
}
variable "worker_replicas" {
  description = "number of replicas of the workers"
  default     = 1
}
variable "key_vault_resource_group" {
  default     = null
  description = "The name of the key vault resorce group"
}

variable "azure_maintenance_window" {
  default = null
}
variable "postgres_flexible_server_sku" {
  default = "B_Standard_B1ms"
}
variable "postgres_enable_high_availability" {
  default = false
}
variable "azure_enable_backup_storage" {
  default = false
}
variable "enable_container_monitoring" {
  default = false
}

variable "statuscake_contact_groups" {
  default     = []
  description = "ID of the contact group in statuscake web UI"
}

variable "statuscake_alerts" {
  type = object({
    website_url    = optional(list(string), [])
    ssl_url        = optional(list(string), [])
    contact_groups = optional(list(number), [])
  })
  default = {}
}

locals {
  postgres_ssl_mode       = var.enable_postgres_ssl ? "require" : "disable"
  app_env_values_from_yml = yamldecode(file("${path.module}/config/${var.config}_app_env.yml"))

  ingress_domain_map = {
    INGRESS_CLAIMS_HOST     = "track-and-pay-${var.environment}.${module.cluster_data.ingress_domain}"
    INGRESS_PLACEMENTS_HOST = "manage-school-placements-${var.environment}.${module.cluster_data.ingress_domain}"
  }

  claims_domain_map = (
    contains(keys(local.app_env_values_from_yml), "CLAIMS_HOST") ?
    {} : { CLAIMS_HOST = local.ingress_domain_map["INGRESS_CLAIMS_HOST"] }
  )

  placements_domain_map = (
    contains(keys(local.app_env_values_from_yml), "PLACEMENTS_HOST") ?
    {} : { PLACEMENTS_HOST = local.ingress_domain_map["INGRESS_PLACEMENTS_HOST"] }
  )

  app_env_values = merge(
    local.app_env_values_from_yml,
    local.claims_domain_map,
    local.placements_domain_map
  )

  app_resource_group_name = "${var.azure_resource_prefix}-${var.service_short}-${var.config_short}-rg"

  # If there are multiple environments per config (as in review apps), we need the environment name without hyphens.
  # e.g.
  #   production   -> pd
  #   review-12345 -> review-12345
  #
  # In this case, the `environment` variable value for review apps are only the PR number, but the code below is generic.
  # e.g.
  #   12345 -> 12345
  environment_compact = var.config == var.environment ? var.config_short : replace(var.environment, "-", "")

  # Combined with the `environment_compact` variable, this will be the name of the storage account, as storage account names don't allow hyphens.
  # e.g.
  #   production   -> [s189p01][ittms][pd]appsa       -> s189p01ittmspdappsa
  #   review-12345 -> [s189t01][ittms][rv-12345]appsa -> s189t01ittmsrv12345appsa
  azure_storage_account_name = "${var.azure_resource_prefix}${var.service_short}${local.environment_compact}appsa"
  azure_storage_access_key   = azurerm_storage_account.general_storage_account.primary_access_key
  azure_storage_container    = azurerm_storage_container.general_container.name
}
