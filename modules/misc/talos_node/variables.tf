variable "talos_version" {
  description = "The version used to create the talos image"
  type        = string
}

variable "talos_extensions" {
  description = "The extensions to use in creating the factory.talos.dev installer image"
  type        = list(string)
  default     = []
}

variable "image_arch" {
  description = "The architecture if the install image"
  type        = string
  default     = "amd64"
}

variable "image_platform" {
  description = "The platform for the image created for"
  type        = string
  default     = "metal"
}

variable "is_image_secureboot" {
  description = "Wether to use the installer with secureboot or not"
  type        = bool
  default     = false
}

variable "machine_secrets" {
  description = "The secret used to connect Talos nodes together"
  sensitive   = true
}

variable "client_configuration" {
  description = "The secret used to authenticate to a Talos node"
  sensitive   = true
}

variable "node_is_controlplane" {
  description = "Wether to configure this node as a controlplane or a worker node"
  type        = bool
  default     = false
}

variable "kubernetes_version" {
  description = "The version of kubernetes for talos to use"
  type        = string
  default     = "v1.33.0"
}

variable "talos_extra_kernel_args" {
  description = "Extra kernels arguments to give to the node"
  type        = list(string)
  default     = []
}

variable "talos_kernel_modules" {
  description = "Kernel Modules to laod into the node"
  type        = list(string)
  default     = []
}

variable "cluster_name" {
  description = "The name of the cluster that the node will join"
  type        = string
}

variable "cluster_endpoint" {
  description = "The cluster endpoint for the node to join"
  type        = string
  default     = null
  nullable    = true
}
variable "cluster_inline_manifests" {
  description = "The paths to manifest files to load onto Talos after cluster creation"
  type = map(string)
  default = {}
}
variable "cluster_extra_manifests" {
  description = "An array of raw text urls containing extra manifests to download and load after cluster creation"
  type = list(string)
  default = []
}
variable "node_address" {
  description = "The network reachable address of the Talos node to configure"
  type        = string
}

variable "config_templates" {
  description = "The map locations of the template and the parameters for it"
  # type        = map(map({}))
  default     = {}
}

variable "node_labels" {
  description = "The labels added to the node"
  type        = map(string)
  default     = {}
}
variable "node_annotations" {
  description = "The annotations added to the node"
  type        = map(string)
  default     = {}
}
variable "node_taints" {
  description = "The taints added to the node"
  type        = map(string)
  default     = {}
}
variable "use_wireguard" {
  description = "Wether to use wireguard as the underlying network or not"
  type        = bool
  default     = false
}

variable "wg_iface_name" {
  description = "The name of the wireguard interface on the Talos machine config"
  type        = string
  default     = "wgc"

}
variable "wg_listen_port" {
  description = "This node's listening port for wireguard"
  type        = number
  nullable    = true
  default     = null
  validation {
    condition     = var.use_wireguard == false || var.wg_listen_port != null
    error_message = "wg_listen_port must be set if you use use_wireguard."
  }
}

variable "wg_peers" {
  description = "Other Talos nodes connected to this one through wireguard"
  type = list(object({
    publicKey                   = string
    endpoint                    = string
    allowedIPs                  = list(string)
    persistentKeepaliveInterval = optional(string, "5s")
  }))
  default = []
}

variable "wg_addresses" {
  description = "The addresses this node is reachable within the wg network"
  type        = list(string)
  default     = null
  nullable    = true
  validation {
    condition     = var.use_wireguard == false || var.wg_addresses != null
    error_message = "wg_addresses must be set if you use use_wireguard."
  }
}

variable "wg_keep_alive" {
  description = "How long is the wg connection kept alive"
  type        = string
  default     = "5s"
}
variable "wg_allowed_ips" {
  description = "Allowed ip addresses this node can access(careful that it doesn't overlap with other networks, disabling network access)"
  type        = list(string)
  default     = []
}

variable "wg_override_endpoint" {
  description = "In case of tunneling, you should specify the endpoint of the tunnel"
  type        = string
  default     = null
  nullable    = true
}
variable "wg_mtu" {
  description = "The mtu of the wireguard packets"
  type = number
  default = 1500
}
variable "apply_talos_config" {
  description = "wether to apply the auto generated config or not, this is mainly for debugging"
  type        = bool
  default     = true
}