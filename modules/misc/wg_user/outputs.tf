output "wg_peer" {
  description = "This node's wireguard peer information to connect to other nodes"
  value = merge(
    {
      publicKey                   = wireguard_asymmetric_key.this.public_key
      allowedIPs                  = var.wg_allowed_ips == [] ? var.wg_addresses : var.wg_allowed_ips
      persistentKeepaliveInterval = var.wg_keep_alive
    },
    var.wg_preshared_key != null ? { presharedKey = var.wg_preshared_key } : {}
  )
}