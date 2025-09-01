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

variable "use_wireguard" {
  description = "Enable WireGuard for nodes"
  type        = bool
  default     = true
}

variable "wg_listen_port" {
  description = "WireGuard listen port"
  type        = number
  default     = 51820
}

variable "home_controlplane_address" {
  description = "IP address of the controlplane node"
  type        = string
  default     = "192.168.1.5"
}

variable "home_worker_a_address" {
  description = "IP address of worker A"
  type        = string
  default     = "192.168.1.3"
}

variable "home_worker_b_address" {
  description = "IP address of worker B"
  type        = string
  default     = "192.168.1.24"
}

variable "home_controlplane_wg_address" {
  description = "WireGuard address of the controlplane node"
  type        = list(string)
  default     = ["10.10.0.1/24"]
}

variable "home_worker_a_wg_address" {
  description = "WireGuard address of worker A"
  type        = list(string)
  default     = ["10.10.0.2"]
}

variable "home_worker_b_wg_address" {
  description = "WireGuard address of worker B"
  type        = list(string)
  default     = ["10.10.0.3"]
}

variable "is_image_secureboot" {
  description = "Enable secure boot image"
  type        = bool
  default     = true
}