
locals {
  #Machine role
  machine_type = var.node_is_controlplane ? "controlplane" : "worker"

  #Schematic config section
  schematic = yamlencode(
    {
      customization = {
        extraKernelArgs = var.talos_extra_kernel_args
        systemExtensions = {
          officialExtensions = length(var.talos_extensions) > 0 ? data.talos_image_factory_extensions_versions.this.extensions_info[*].name : []
        }
      }
    }
  )
  #machine config section
  install_image = yamlencode({
    machine = {
      install = {
        image = var.is_image_secureboot ? data.talos_image_factory_urls.this.urls.installer_secureboot : data.talos_image_factory_urls.this.urls.installer
      }
    }
  })
  node_labels = yamlencode({
    machine = {
      nodeLabels = var.node_labels
    }
  })
  node_annotations = yamlencode({
    machine = {
      nodeAnnotations = var.node_annotations
    }
  })
  node_taints = yamlencode({
    machine = {
      nodeTaints = var.node_taints
    }
  })
  wg_interface_config = yamlencode({
    machine = {
      network = {
        interfaces = [
          {
            interface = var.wg_iface_name
            addresses = var.wg_addresses
            wireguard = {
              privateKey = wireguard_asymmetric_key.this.private_key
              listenPort = var.wg_listen_port
              peers      = var.wg_peers
            }
          }
        ]
      }
    }
  })
  config_templates = [
    for template, paramater in var.config_templates :
    templatefile(template, paramater)
  ]
  config_patches = concat(
    [
      local.install_image,
      local.wg_interface_config,
      local.node_labels,
      local.node_annotations,
      local.node_taints
    ],
    local.config_templates
  )
}

# -- Wireguard --
resource "wireguard_asymmetric_key" "this" {
}

# -- Extensions --
data "talos_image_factory_extensions_versions" "this" {
  talos_version = var.talos_version
  filters = {
    names = var.talos_extensions
  }
}

resource "talos_image_factory_schematic" "this" {
  schematic = local.schematic
}

data "talos_image_factory_urls" "this" {
  talos_version = var.talos_version
  schematic_id  = talos_image_factory_schematic.this.id
  architecture  = var.image_arch
  platform      = var.image_platform
}

# -- Node Configuration --
data "talos_machine_configuration" "this" {
  talos_version      = var.talos_version
  cluster_name       = var.cluster_name
  machine_type       = local.machine_type
  cluster_endpoint   = var.cluster_endpoint
  machine_secrets    = var.machine_secrets
  kubernetes_version = var.kubernetes_version
  config_patches     = local.config_patches
}

resource "talos_machine_configuration_apply" "this" {
  count                       = var.apply_talos_config ? 1 : 0
  client_configuration        = var.client_configuration
  machine_configuration_input = data.talos_machine_configuration.this.machine_configuration
  node                        = var.node_address
}