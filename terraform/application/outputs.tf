output "ingress_hostnames" {
  value = [local.ingress_domain_map["INGRESS_CLAIMS_HOST"], local.ingress_domain_map["INGRESS_PLACEMENTS_HOST"]]
}
