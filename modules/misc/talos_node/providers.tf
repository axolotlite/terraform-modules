terraform {
  required_providers {
    talos = {
      source  = "siderolabs/talos"
      version = "0.8.1"
    }
    wireguard = {
      source  = "OJFord/wireguard"
      version = "0.4.0"
    }
  }
}