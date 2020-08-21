locals {
  stable_config = {
    environment_name = var.environment_name
    
    nsxt_host     = var.nsxt_host
    nsxt_username = var.nsxt_username
    nsxt_password = var.nsxt_password
    // nsxt_ca_cert  = var.nsxt_ca_cert

    ops_manager_public_ip       = var.ops_manager_public_ip
    ops_manager_private_ip      = nsxt_nat_rule.dnat_om.translated_network

    allow_unverified_ssl      = var.allow_unverified_ssl
    disable_ssl_verification  = !var.allow_unverified_ssl
  }
}

output "stable_config" {
  value     = jsonencode(local.stable_config)
  sensitive = true
}
