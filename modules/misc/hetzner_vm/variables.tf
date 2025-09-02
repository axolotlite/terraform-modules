variable "vm_name" {
  description = "The name of the VM created by hetzner"
  type = string
}
variable "server_type" {
  description = "The server type for the hetzner vm"
  type = string
}
variable "labels" {
  description = "The labels map used for the vm"
  type = map(string)
  default = {}
}
variable "enabled_ipv4" {
  description = "Enable ipv4 for the vm"
  type = bool
  default = true
}

variable "firewall_rules" {
  description = "Firewall rules to apply to the VM"
  type = list(any)
  default = []
}

variable "location" {
  description = "Location to place the hetzner vm"
  type = string
  default = "nbg1"
}
variable "image_id" {
  description = "Image name on hetzner cloud"
  type = string
}
variable "user_data" {
  description = "The start/init scripts"
  type = string
  default = null
  nullable = true
}

variable "ssh_keys" {
  description = "SSH Keys injected into the vm on startup"
  type = list(string)
  default = []
}