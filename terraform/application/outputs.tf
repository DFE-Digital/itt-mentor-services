output "hostname" {
  value = [local.app_env_values["CLAIMS_HOST"], local.app_env_values["PLACEMENTS_HOST"]]
}
