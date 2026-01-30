module "application_configuration" {
  source = "./vendor/modules/aks//aks/application_configuration"

  namespace              = var.namespace
  environment            = var.environment
  azure_resource_prefix  = var.azure_resource_prefix
  service_short          = var.service_short
  config_short           = var.config_short
  secret_key_vault_short = "app"

  # Delete for non rails apps
  is_rails_application = true

  config_variables = merge(
    local.app_env_values,
    {
      ENVIRONMENT_NAME = var.environment
      PGSSLMODE        = local.postgres_ssl_mode
  })

  secret_variables = {
    DATABASE_URL               = module.postgres.url
    AZURE_STORAGE_ACCOUNT_NAME = local.azure_storage_account_name
    AZURE_STORAGE_ACCESS_KEY   = local.azure_storage_access_key
    AZURE_STORAGE_CONTAINER    = local.azure_storage_container
  }
}

module "web_application" {
  source     = "./vendor/modules/aks//aks/application"
  depends_on = [module.migrations_job]

  is_web = true

  namespace    = var.namespace
  environment  = var.environment
  service_name = var.service_name
  web_external_hostnames = [
    local.ingress_domain_map["INGRESS_CLAIMS_HOST"]
  ]

  cluster_configuration_map  = module.cluster_data.configuration_map
  kubernetes_config_map_name = module.application_configuration.kubernetes_config_map_name
  kubernetes_secret_name     = module.application_configuration.kubernetes_secret_name
  replicas                   = var.app_replicas
  docker_image               = var.docker_image
  enable_logit               = true
  istio_enabled              = var.istio_enabled

  run_as_non_root = var.run_as_non_root

  send_traffic_to_maintenance_page = false
}

module "worker_application" {
  source     = "./vendor/modules/aks//aks/application"
  depends_on = [module.migrations_job]

  name    = "worker"
  is_web  = false
  command = ["bundle", "exec", "good_job", "start"]

  namespace    = var.namespace
  environment  = var.environment
  service_name = var.service_name

  cluster_configuration_map  = module.cluster_data.configuration_map
  kubernetes_config_map_name = module.application_configuration.kubernetes_config_map_name
  kubernetes_secret_name     = module.application_configuration.kubernetes_secret_name
  replicas                   = var.worker_replicas
  docker_image               = var.docker_image
  enable_logit               = true
  enable_gcp_wif             = true

  run_as_non_root = var.run_as_non_root
}
