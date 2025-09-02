locals {
  ## Block access to everything 
  base_firewall_rules = [
    {
      description = "block all tcp traffic"
      direction   = "in"
      protocol    = "tcp"
      source_ips  = ["0.0.0.0/0", "::/0"]
      port        = "1-65535"
      action      = "drop"
    },
    {
      description = "block all udp traffic"
      direction   = "in"
      protocol    = "udp"
      source_ips  = ["0.0.0.0/0", "::/0"]
      port        = "1-65535"
      action      = "drop"
    },
    {
      description = "block all icmp traffic"
      direction   = "in"
      protocol    = "icmp"
      source_ips  = ["0.0.0.0/0", "::/0"]
      action      = "drop"
    }
  ]
  # create a new firewall list based on base_firewall_rules but with direction-protocol-port as key
  # this is needed to avoid duplicate rules
  firewall_rules = {
    for rule in local.base_firewall_rules :
    format("%s-%s-%s",
      lookup(rule, "direction", "null"),
      lookup(rule, "protocol", "null"),
      lookup(rule, "port", "null")
    ) => rule
  }

  # do the same for var.extra_firewall_rules
  extra_firewall_rules = {
    for rule in var.firewall_rules :
    format("%s-%s-%s",
      lookup(rule, "direction", "null"),
      lookup(rule, "protocol", "null"),
      lookup(rule, "port", "null")
    ) => rule
  }

  # merge the two lists
  firewall_rules_merged = merge(local.firewall_rules, local.extra_firewall_rules)

  # convert the merged list back to a list
  firewall_rules_list = values(local.firewall_rules_merged)
}

resource "hcloud_firewall" "this" {
  name = "${var.vm_name}-firewall"
  dynamic "rule" {
    for_each = local.firewall_rules_list
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