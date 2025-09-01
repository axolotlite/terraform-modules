# Talos Node module

This module allows you to easily create a talos node using terraform and even applying manifest patches to it.
It also supports usings Talos' built-in wireguard support, and allows for easy wireguard network peering.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_talos"></a> [talos](#requirement\_talos) | 0.8.1 |
| <a name="requirement_wireguard"></a> [wireguard](#requirement\_wireguard) | 0.4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_talos"></a> [talos](#provider\_talos) | 0.8.1 |
| <a name="provider_wireguard"></a> [wireguard](#provider\_wireguard) | 0.4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [talos_image_factory_schematic.this](https://registry.terraform.io/providers/siderolabs/talos/0.8.1/docs/resources/image_factory_schematic) | resource |
| [talos_machine_configuration_apply.this](https://registry.terraform.io/providers/siderolabs/talos/0.8.1/docs/resources/machine_configuration_apply) | resource |
| [wireguard_asymmetric_key.this](https://registry.terraform.io/providers/OJFord/wireguard/0.4.0/docs/resources/asymmetric_key) | resource |
| [talos_image_factory_extensions_versions.this](https://registry.terraform.io/providers/siderolabs/talos/0.8.1/docs/data-sources/image_factory_extensions_versions) | data source |
| [talos_image_factory_urls.this](https://registry.terraform.io/providers/siderolabs/talos/0.8.1/docs/data-sources/image_factory_urls) | data source |
| [talos_machine_configuration.this](https://registry.terraform.io/providers/siderolabs/talos/0.8.1/docs/data-sources/machine_configuration) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_client_configuration"></a> [client\_configuration](#input\_client\_configuration) | The secret used to authenticate to a Talos node | `any` | n/a | yes |
| <a name="input_cluster_endpoint"></a> [cluster\_endpoint](#input\_cluster\_endpoint) | The cluster endpoint for the node to join | `string` | `null` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the cluster that the node will join | `string` | n/a | yes |
| <a name="input_config_templates"></a> [config\_templates](#input\_config\_templates) | The map locations of the template and the parameters for it | `map(map(string))` | `{}` | no |
| <a name="input_image_arch"></a> [image\_arch](#input\_image\_arch) | The architecture if the install image | `string` | `"amd64"` | no |
| <a name="input_image_platform"></a> [image\_platform](#input\_image\_platform) | The platform for the image created for | `string` | `"metal"` | no |
| <a name="input_is_image_secureboot"></a> [is\_image\_secureboot](#input\_is\_image\_secureboot) | Wether to use the installer with secureboot or not | `bool` | `false` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | The version of kubernetes for talos to use | `string` | `"v1.33.0"` | no |
| <a name="input_machine_secrets"></a> [machine\_secrets](#input\_machine\_secrets) | The secret used to connect Talos nodes together | `any` | n/a | yes |
| <a name="input_node_address"></a> [node\_address](#input\_node\_address) | The network reachable address of the Talos node to configure | `string` | n/a | yes |
| <a name="input_node_is_controlplane"></a> [node\_is\_controlplane](#input\_node\_is\_controlplane) | Wether to configure this node as a controlplane or a worker node | `bool` | `false` | no |
| <a name="input_talos_extensions"></a> [talos\_extensions](#input\_talos\_extensions) | The extensions to use in creating the factory.talos.dev installer image | `list(string)` | `[]` | no |
| <a name="input_talos_extra_kernel_args"></a> [talos\_extra\_kernel\_args](#input\_talos\_extra\_kernel\_args) | Extra kernels arguments to give to the node | `list(string)` | `[]` | no |
| <a name="input_talos_version"></a> [talos\_version](#input\_talos\_version) | The version used to create the talos image | `string` | n/a | yes |
| <a name="input_use_wireguard"></a> [use\_wireguard](#input\_use\_wireguard) | Wether to use wireguard as the underlying network or not | `bool` | `false` | no |
| <a name="input_wg_addresses"></a> [wg\_addresses](#input\_wg\_addresses) | The addresses this node is reachable within the wg network | `list(string)` | `null` | no |
| <a name="input_wg_allowed_ips"></a> [wg\_allowed\_ips](#input\_wg\_allowed\_ips) | Allowed ip addresses this node can access(careful that it doesn't overlap with other networks, disabling network access) | `list(string)` | `[]` | no |
| <a name="input_wg_iface_name"></a> [wg\_iface\_name](#input\_wg\_iface\_name) | The name of the wireguard interface on the Talos machine config | `string` | `"wgc"` | no |
| <a name="input_wg_keep_alive"></a> [wg\_keep\_alive](#input\_wg\_keep\_alive) | How long is the wg connection kept alive | `string` | `"5s"` | no |
| <a name="input_wg_listen_port"></a> [wg\_listen\_port](#input\_wg\_listen\_port) | This node's listening port for wireguard | `number` | `null` | no |
| <a name="input_wg_override_endpoint"></a> [wg\_override\_endpoint](#input\_wg\_override\_endpoint) | In case of tunneling, you should specify the endpoint of the tunnel | `string` | `null` | no |
| <a name="input_wg_peers"></a> [wg\_peers](#input\_wg\_peers) | Other Talos nodes connected to this one through wireguard | <pre>list(object({<br/>    publicKey = string<br/>    endpoint = string<br/>    allowedIPs = list(string)<br/>    persistentKeepaliveInterval = optional(string,"5s")<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_wg_peer"></a> [wg\_peer](#output\_wg\_peer) | This nodes wireguard peer information to connect to other nodes |

