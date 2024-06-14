module "statuscake" {

  count = var.enable_monitoring? 1 : 0
  source = "./vendor/modules/aks//monitoring/statuscake"

  uptime_urls    = var.statuscake_alerts.website_url
  ssl_urls       = var.statuscake_alerts.ssl_url
  contact_groups = var.statuscake_alerts.contact_groups
}
