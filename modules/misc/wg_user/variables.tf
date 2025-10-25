variable "filename" {
  description = "The path and filename to write the wireguard config file to"
  type = string
  default = "./wireguard.conf"
}
variable "wg_iface_name" {
  description = "The name of the wireguard interface on the Talos machine config"
  type        = string
  default     = "wgc"
}
variable "wg_listen_port" {
  description = "This node's listening port for wireguard"
  type        = number
  nullable    = true
  default     = null
}

variable "wg_peers" {
  description = "Other Talos nodes connected to this one through wireguard"
  type = list(object({
    publicKey                   = string
    endpoint                    = string
    allowedIPs                  = list(string)
    persistentKeepaliveInterval = optional(string, "5s")
  }))
  default = []
}

variable "wg_addresses" {
  description = "The addresses this node is reachable within the wg network"
  type        = list(string)
  default     = null
  nullable    = true
}

variable "wg_keep_alive" {
  description = "How long is the wg connection kept alive"
  type        = string
  default     = "5s"
}
variable "wg_allowed_ips" {
  description = "Allowed ip addresses this node can access(careful that it doesn't overlap with other networks, disabling network access)"
  type        = list(string)
  default     = []
}
variable "wg_mtu" {
  description = "The mtu used by the device"
  type = number
  default = 1500
}