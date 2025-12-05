
output "server_ipv4" {
  value = hcloud_server.vb.ipv4_address
}

output "server_ipv6" {
  value = hcloud_server.vb.ipv6_address
}
