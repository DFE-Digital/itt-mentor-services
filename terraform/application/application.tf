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
    DATABASE_URL = module.postgres.url
  }
}

# Run database migrations
# https://guides.rubyonrails.org/active_record_migrations.html#preparing-the-database
# https://github.com/ilyakatz/data-migrate
# Terraform waits for this to complete before starting web_application and worker_application
resource "kubernetes_job" "migrations" {
  metadata {
    name      = "${var.service_name}-${var.environment}-migrations"
    namespace = var.namespace
  }

  spec {
    template {
      metadata {}
      spec {
        container {
          name    = "migrate"
          image   = var.docker_image
          command = ["bundle"]
          args    = ["exec", "rails", "db:prepare", "data:migrate"]

          env_from {
            config_map_ref {
              name = module.application_configuration.kubernetes_config_map_name
            }
          }

          env_from {
            secret_ref {
              name = module.application_configuration.kubernetes_secret_name
            }
          }
        }

        restart_policy = "Never"
      }
    }

    backoff_limit = 1
  }

  wait_for_completion = true

  timeouts {
    create = "11m"
    update = "11m"
  }
}

module "web_application" {
  source = "./vendor/modules/aks//aks/application"
  depends_on = [kubernetes_job.migrations]

  is_web = true

  namespace    = var.namespace
  environment  = var.environment
  service_name = var.service_name
  web_external_hostnames = [
    local.ingress_domain_map["INGRESS_CLAIMS_HOST"],
    local.ingress_domain_map["INGRESS_PLACEMENTS_HOST"]
  ]

  cluster_configuration_map  = module.cluster_data.configuration_map
  kubernetes_config_map_name = module.application_configuration.kubernetes_config_map_name
  kubernetes_secret_name     = module.application_configuration.kubernetes_secret_name
  replicas                   = var.app_replicas
  docker_image               = var.docker_image
  enable_logit               = true
}

module "worker_application" {
  source = "./vendor/modules/aks//aks/application"
  depends_on = [kubernetes_job.migrations]

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
}
