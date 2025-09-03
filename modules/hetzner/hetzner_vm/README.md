# Hetzner VM

This creates a simple hetzner vm## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_hcloud"></a> [hcloud](#requirement\_hcloud) | ~> 1.45 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_hcloud"></a> [hcloud](#provider\_hcloud) | ~> 1.45 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [hcloud_firewall.this](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/firewall) | resource |
| [hcloud_server.this](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/server) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_enabled_ipv4"></a> [enabled\_ipv4](#input\_enabled\_ipv4) | Enable ipv4 for the vm | `bool` | `true` | no |
| <a name="input_firewall_rules"></a> [firewall\_rules](#input\_firewall\_rules) | Firewall rules to apply to the VM | `list(any)` | `[]` | no |
| <a name="input_image_id"></a> [image\_id](#input\_image\_id) | Image name on hetzner cloud | `string` | n/a | yes |
| <a name="input_labels"></a> [labels](#input\_labels) | The labels map used for the vm | `map(string)` | `{}` | no |
| <a name="input_location"></a> [location](#input\_location) | Location to place the hetzner vm | `string` | `"nbg1"` | no |
| <a name="input_server_type"></a> [server\_type](#input\_server\_type) | The server type for the hetzner vm | `string` | n/a | yes |
| <a name="input_ssh_keys"></a> [ssh\_keys](#input\_ssh\_keys) | SSH Keys injected into the vm on startup | `list(string)` | `[]` | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | The start/init scripts | `string` | `null` | no |
| <a name="input_vm_name"></a> [vm\_name](#input\_vm\_name) | The name of the VM created by hetzner | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ipv4_address"></a> [ipv4\_address](#output\_ipv4\_address) | n/a |
