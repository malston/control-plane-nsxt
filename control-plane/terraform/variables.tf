variable "ops_manager_public_ip" {
  description = "The public IP Address of the Operations Manager. The om's DNS (e.g. `om.system.tld`) should resolve to this IP, e.g. `10.195.74.16`"
  type        = string
}

variable "nat_gateway_ip" {
  description = "The IP Address of the SNAT rule for egress traffic from the Infra & Deployment subnets; should be in the same subnet as the external IP pool, but not in the range of available IP addresses, e.g. `10.195.74.17`"
  type        = string
}

variable "subnet_prefix" {
  type = string
  default = "172.16"
}

variable "allow_unverified_ssl" {
  default = false
  type    = "string"
}

variable "nsxt_host" {
  default     = ""
  description = "The nsx-t host."
  type        = "string"
}

variable "nsxt_username" {
  default     = ""
  description = "The nsx-t username."
  type        = "string"
}

variable "nsxt_password" {
  default     = ""
  description = "The nsx-t password."
  type        = "string"
}

// variable "nsxt_ca_cert" {
//   type    = string
// }

variable "east_west_transport_zone_name" {
  default     = ""
  description = "The name of the overlay transport zone."
  type        = "string"
}

variable "nsxt_edge_cluster_name" {
  default     = ""
  description = "The name of the edge cluster."
  type        = "string"
}

variable "nsxt_t0_router_name" {
  default     = ""
  description = "The name of the logical tier 0 router."
  type        = "string"
}

variable "credhub_vip_server" {
  default     = ""
  description = "IP Address for credhub loadbalancer"
  type        = "string"
}

variable "uaa_vip_server" {
  default     = ""
  description = "IP Address for uaa loadbalancer"
  type        = "string"
}

variable "minio_vip_server" {
  default     = ""
  description = "IP Address for minio loadbalancer"
  type        = "string"
}

variable "environment_name" {
  description = "An identifier used to tag resources; examples: `dev`, `EMEA`, `prod`"
  type        = string
}
