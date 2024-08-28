module "statuscake" {

  count = var.enable_monitoring? 1 : 0
  source = "./vendor/modules/aks//monitoring/statuscake"

  uptime_urls    = var.statuscake_alerts.website_url
  ssl_urls       = var.statuscake_alerts.ssl_url
  contact_groups = var.statuscake_alerts.contact_groups

  heartbeat_names  = ["heartbeat-check"]
  heartbeat_period = 600  # The period in seconds within which a heartbeat must be received
}
