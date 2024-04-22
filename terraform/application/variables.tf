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
  default = 1
}

variable "sidekiq_replicas" {
  description = "number of replicas of the sidekiq"
  default = 1
}

variable "key_vault_resource_group" {
  default     = null
  description = "The name of the key vault resorce group"
}

variable "statuscake_password_name" {
  default     = "SC-PASSWORD"
  description = "The name of the statuscake password"
}

variable "infra_key_vault_name" {
  default     = null
  description = "The name of the key vault to get postgres and redis"
}

variable "statuscake_alerts" {
  type = map(
    object({
      website_url   = optional(list(string), [])
      ssl_url       = optional(list(string), [])
      contact_groups = optional(list(number), [])
    })
  )
  default = {}
}

locals {
  postgres_ssl_mode       = var.enable_postgres_ssl ? "require" : "disable"
  app_env_values_from_yml = yamldecode(file("${path.module}/config/${var.config}_app_env.yml"))
  ingress_claims_domain_map = (
    contains(keys(local.app_env_values_from_yml), "CLAIMS_HOST") ?
    {} : { CLAIMS_HOST = "track-and-pay-${var.environment}.${module.cluster_data.ingress_domain}" }
  )
  ingress_placements_domain_map = (
    contains(keys(local.app_env_values_from_yml), "PLACEMENTS_HOST") ?
    {} : { PLACEMENTS_HOST = "manage-school-placements-${var.environment}.${module.cluster_data.ingress_domain}" }
  )
  app_env_values = merge(
    local.app_env_values_from_yml,
    local.ingress_claims_domain_map,
    local.ingress_placements_domain_map
  )
}
