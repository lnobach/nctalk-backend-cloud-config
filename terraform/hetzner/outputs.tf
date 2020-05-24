
output "server_ipv4" {
  value = hcloud_server.vb.ipv4_address
}

output "server_ipv6" {
  value = hcloud_server.vb.ipv6_address
}

output "float_ipv4" {
  value = hcloud_floating_ip.vb_v4.ip_address
}

output "float_ipv6" {
  value = hcloud_floating_ip.vb_v6.ip_address
}
