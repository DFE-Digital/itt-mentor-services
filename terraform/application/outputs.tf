output "ingress_hostnames" {
  value = [local.ingress_domain_map["INGRESS_CLAIMS_HOST"], local.ingress_domain_map["INGRESS_PLACEMENTS_HOST"]]
}

output "external_urls" {
  value = [for domain in ["CLAIMS_HOST", "PLACEMENTS_HOST"] : "https://${local.app_env_values[domain]}/"]
}
