terraform {
  required_providers {
    talos = {
      source  = "siderolabs/talos"
      version = "0.8.1"
    }
  }
}

resource "talos_machine_secrets" "this" {}

module "home_controlplane" {
  source               = "../../"
  talos_version        = var.talos_version
  cluster_endpoint     = var.cluster_endpoint
  machine_secrets      = talos_machine_secrets.this.machine_secrets
  node_address         = var.home_controlplane_address
  client_configuration = talos_machine_secrets.this.client_configuration
  node_is_controlplane = true
  cluster_name         = var.cluster_name
  is_image_secureboot  = var.is_image_secureboot
  talos_extensions     = ["intel-ucode"]
}

## Bootstrap the cluster once it's done creating
resource "talos_machine_bootstrap" "this" {
  depends_on           = [module.home_controlplane]
  node                 = var.home_controlplane_address
  client_configuration = talos_machine_secrets.this.client_configuration
}

## Create the relevant config files for testing
data "talos_client_configuration" "this" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints            = [var.cluster_endpoint]
}

resource "local_file" "talosconfig" {
  content  = data.talos_client_configuration.this.talos_config
  filename = "${path.module}/talosconfig"
}

resource "talos_cluster_kubeconfig" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoint             = var.home_controlplane_address
  node                 = var.home_controlplane_address
}

resource "local_file" "kubeconfig" {
  content  = talos_cluster_kubeconfig.this.kubeconfig_raw
  filename = "${path.module}/kubeconfig"
}
