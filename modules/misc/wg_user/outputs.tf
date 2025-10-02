output "wg_peer" {
  description = "This nodes wireguard peer information to connect to other nodes"
  value = {
    publicKey                   = wireguard_asymmetric_key.this.public_key
    endpoint                    = "" #Not needed for user
    allowedIPs                  = var.wg_allowed_ips == [] ? var.wg_addresses : var.wg_allowed_ips
    persistentKeepaliveInterval = var.wg_keep_alive
  }
}