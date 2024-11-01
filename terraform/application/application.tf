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

# Run database migrations
# https://guides.rubyonrails.org/active_record_migrations.html#preparing-the-database
# Terraform waits for this to complete before starting web_application and worker_application
resource "kubernetes_job" "migrations" {
  metadata {
    name      = "${var.service_name}-${var.environment}-migrations"
    namespace = var.namespace
  }

  spec {
    template {
      metadata {
        labels = { app = "${var.service_name}-${var.environment}-migrations" }
        annotations = {
          "logit.io/send"        = "true"
          "fluentbit.io/exclude" = "true"
        }
      }

      spec {
        container {
          name    = "migrate"
          image   = var.docker_image
          command = ["bundle"]
          args    = ["exec", "rails", "db:prepare"]

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

          resources {
            requests = {
              cpu    = module.cluster_data.configuration_map.cpu_min
              memory = "1Gi"
            }
            limits = {
              cpu    = 1
              memory = "1Gi"
            }
          }

          security_context {
            allow_privilege_escalation = false

            seccomp_profile {
              type = "RuntimeDefault"
            }

            capabilities {
              drop = ["ALL"]
              add  = ["NET_BIND_SERVICE"]
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
  source     = "./vendor/modules/aks//aks/application"
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

  send_traffic_to_maintenance_page = false
}

module "worker_application" {
  source     = "./vendor/modules/aks//aks/application"
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
