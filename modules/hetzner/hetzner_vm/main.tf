locals {

  # do the same for var.extra_firewall_rules
  extra_firewall_rules = {
    for rule in var.firewall_rules :
    format("%s-%s-%s",
      lookup(rule, "direction", "null"),
      lookup(rule, "protocol", "null"),
      lookup(rule, "port", "null")
    ) => rule
  }
}

resource "hcloud_firewall" "this" {
  name = "${var.vm_name}-firewall"
  dynamic "rule" {
    for_each = local.extra_firewall_rules
    content {
      description     = coalesce(rule.value.description,"Firewall Rule")
      direction       = rule.value.direction
      protocol        = rule.value.protocol
      port            = lookup(rule.value, "port", null)
      destination_ips = lookup(rule.value, "destination_ips", [])
      source_ips      = lookup(rule.value, "source_ips", [])
    }
  }
  labels = var.labels
}

resource "hcloud_server" "this" {
  location = var.location
  name               = var.vm_name
  image              = var.image_id
  server_type        = var.server_type

  ssh_keys = var.ssh_keys
  user_data = var.user_data

  labels = var.labels

  firewall_ids = [
    hcloud_firewall.this.id
  ]

  public_net {
    ipv4_enabled = var.enabled_ipv4
    ipv6_enabled = true # Always true because it's free
  }
}