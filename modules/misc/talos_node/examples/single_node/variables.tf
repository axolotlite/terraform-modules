variable "talos_version" {
  description = "Talos version for nodes"
  type        = string
  default     = "v1.10.7"
}

variable "cluster_name" {
  description = "Name of the Talos cluster"
  type        = string
  default     = "test-cluster"
}

variable "cluster_endpoint" {
  description = "Cluster endpoint URL"
  type        = string
  default     = "https://192.168.1.5:6443"
}

variable "home_controlplane_address" {
  description = "IP address of the controlplane node"
  type        = string
  default     = "192.168.1.5"
}

variable "is_image_secureboot" {
  description = "Enable secure boot image"
  type        = bool
  default     = true
}