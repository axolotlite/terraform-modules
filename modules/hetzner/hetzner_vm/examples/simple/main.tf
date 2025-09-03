
module "hetzner_vm" {
  source = "./modules/hetzner"
  vm_name = var.vm_name
  server_type = var.server_type
  image_id = var.image_id
  firewall_rules = local.firewall_rules
}