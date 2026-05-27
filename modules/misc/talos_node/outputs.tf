output "wg_peer" {
  description = "This node's wireguard peer information to connect to other nodes"
  value = var.use_wireguard ? merge(
    {
      publicKey = try(wireguard_asymmetric_key.this[0].public_key, null)
      endpoint  = var.wg_override_endpoint != null ? var.wg_override_endpoint : "${var.node_address}:${var.wg_listen_port}"
    },
    length(var.wg_allowed_ips) > 0 ? { allowedIPs = var.wg_allowed_ips } : {},
    var.wg_preshared_key != null ? { presharedKey = var.wg_preshared_key } : {},
    var.wg_keep_alive != null ? { persistentKeepaliveInterval = var.wg_keep_alive } : {}
  ) : null
}

output "urls" {
  description = "The image urls for manually updating nodes"
  value       = data.talos_image_factory_urls.this.urls
}