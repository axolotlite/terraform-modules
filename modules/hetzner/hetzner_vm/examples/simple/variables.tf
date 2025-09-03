variable "hcloud_token" {
  description = "The hcloud token"
  type = string
}
variable "vm_name" {
  description = "The name of the hetzner VM"
  type = string
}

variable "server_type" {
  description = "The hetzner VM server type"
  type = string
  default = "cx22"
}

variable "image_id" {
  description = "The id of the image talos will use"
  type = string
  default = "ubuntu-24.04"
}

variable "firewall_rules" {
  description = "list of firewall rules applied to the vm"
  default = []
}