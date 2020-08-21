resource "nsxt_nat_rule" "snat_om" {
  display_name = "${var.environment_name}-snat-om"
  action       = "SNAT"

  logical_router_id = data.nsxt_logical_tier0_router.t0_router.id
  description       = "SNAT Rule for Control Plane Operations Manager"
  enabled           = true
  logging           = false
  nat_pass          = true

  match_source_network = "${var.subnet_prefix}.0.0/16"
  translated_network   = var.nat_gateway_ip
  
  tag {
    scope = "terraform"
    tag   = var.environment_name
  }
}

resource "nsxt_nat_rule" "dnat_om" {
  display_name = "${var.environment_name}-dnat-om"
  action       = "DNAT"

  logical_router_id = data.nsxt_logical_tier0_router.t0_router.id
  description       = "DNAT Rule for Control Plane Operations Manager"
  enabled           = true
  logging           = false
  nat_pass          = true

  match_destination_network = var.ops_manager_public_ip
  translated_network        = "${var.subnet_prefix}.0.10"

  tag {
    scope = "terraform"
    tag   = var.environment_name
  }
}

resource "nsxt_logical_router_link_port_on_tier0" "t0_to_t1_infrastructure" {
  display_name = "${var.environment_name}-T0-to-T1-Infrastructure"

  description       = "Link Port on Logical Tier 0 Router for connecting to Tier 1 Infrastructure Router."
  logical_router_id = data.nsxt_logical_tier0_router.t0_router.id

  tag {
    scope = "terraform"
    tag   = var.environment_name
  }
}

resource "nsxt_logical_tier1_router" "t1_infrastructure" {
  display_name = "${var.environment_name}-T1-Router-Infrastructure"

  description = "Infrastructure Tier 1 Router."
  failover_mode   = "PREEMPTIVE"
  edge_cluster_id = data.nsxt_edge_cluster.edge_cluster.id

  enable_router_advertisement = true
  advertise_connected_routes  = true
  advertise_lb_vip_routes     = true
  advertise_lb_snat_ip_routes = true

  tag {
    scope = "terraform"
    tag   = var.environment_name
  }
}

resource "nsxt_logical_router_link_port_on_tier1" "t1_infrastructure_to_t0" {
  display_name = "${var.environment_name}-T1-Infrastructure-to-T0"

  description                   = "Link Port on Infrastructure Tier 1 Router connecting to Logical Tier 0 Router. Provisioned by Terraform."
  logical_router_id             = nsxt_logical_tier1_router.t1_infrastructure.id
  linked_logical_router_port_id = nsxt_logical_router_link_port_on_tier0.t0_to_t1_infrastructure.id

  tag {
    scope = "terraform"
    tag   = var.environment_name
  }
}

resource "nsxt_logical_switch" "infrastructure_ls" {
  display_name = "${var.environment_name}-Infrastructure"

  transport_zone_id = data.nsxt_transport_zone.east-west-overlay.id
  admin_state       = "UP"

  description      = "Logical Switch for the T1 Infrastructure Router."
  replication_mode = "MTEP"

  tag {
    scope = "terraform"
    tag   = var.environment_name
  }
}

resource "nsxt_logical_port" "infrastructure_lp" {
  display_name = "${var.environment_name}-Infrastructure-lp"

  admin_state       = "UP"
  description       = "Logical Port on the Logical Switch for the T1 Infrastructure Router."
  logical_switch_id = nsxt_logical_switch.infrastructure_ls.id

  tag {
    scope = "terraform"
    tag   = var.environment_name
  }
}

resource "nsxt_logical_router_downlink_port" "infrastructure_dp" {
  display_name = "${var.environment_name}-Infrastructure-dp"

  description                   = "Downlink port connecting Infrastructure router to its Logical Switch"
  logical_router_id             = nsxt_logical_tier1_router.t1_infrastructure.id
  linked_logical_switch_port_id = nsxt_logical_port.infrastructure_lp.id
  ip_address                    = "${var.subnet_prefix}.0.1/24"

  tag {
    scope = "terraform"
    tag   = var.environment_name
  }
}
