module "migrations_job" {
  source = "./vendor/modules/aks//aks/job_configuration"

  namespace              = var.namespace
  environment            = var.environment
  service_name           = var.service_name
  docker_image           = var.docker_image
  commands               = var.commands
  arguments              = var.arguments
  job_name               = var.job_name
  enable_logit           = var.enable_logit

    config_map_ref = module.application_configuration.kubernetes_config_map_name
    secret_ref     = module.application_configuration.kubernetes_secret_name
    cpu            = module.cluster_data.configuration_map.cpu_min

}