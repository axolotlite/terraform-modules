resource "wireguard_asymmetric_key" "this" {
}

resource "wireguard_preshared_key" "this" {
}



resource "local_file" "peer_config" {
    filename = "${var.filename}"
    file_permission = "600"
    content = <<EOT
[Interface]
PrivateKey = ${wireguard_asymmetric_key.this.private_key}
%{ for address in var.wg_addresses ~}
Address = ${address}
%{ endfor ~}
MTU = ${var.wg_mtu}
%{ for peer in var.wg_peers ~}
[Peer]
PublicKey = ${peer.publicKey}
PresharedKey = ${peer.presharedKey}
AllowedIPs = ${join(",", peer.allowedIPs)}
Endpoint = ${peer.endpoint}
PersistentKeepalive = ${replace(peer.persistentKeepaliveInterval, "s", "")}
%{ endfor ~}
EOT
}