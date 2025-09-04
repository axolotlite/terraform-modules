output "wg_peer" {
  description = "This nodes wireguard peer information to connect to other nodes"
  value = var.use_wireguard ? {
    publicKey                   = wireguard_asymmetric_key.this.public_key
    endpoint                    = var.wg_override_endpoint != null ? var.wg_override_endpoint : "${var.node_address}:${var.wg_listen_port}"
    allowedIPs                  = var.wg_allowed_ips == [] ? var.wg_addresses : var.wg_allowed_ips
    persistentKeepaliveInterval = var.wg_keep_alive
  } : null
}

output "urls" {
  description = "The image urls for manually updating nodes"
  value       = data.talos_image_factory_urls.this.urls
}