
provider "hcloud" {
  token = var.hcloud_token
}

data "hcloud_ssh_keys" "my_keys" {
  with_selector = var.ssh_key_selector
}

resource "hcloud_server" "vb" {
  backups     = false
  image       = "centos-8"
  labels      = {}
  location    = var.location
  name        = var.name
  server_type = "cpx11"
  ssh_keys    = data.hcloud_ssh_keys.my_keys.ssh_keys.*.id
  user_data = templatefile("${path.module}/../../cloud-config.template.yaml", {
    cc_server_ipv4      = hcloud_floating_ip.vb_v4.ip_address
    cc_server_ipv6      = cidrhost(hcloud_floating_ip.vb_v6.ip_network, 1)
    cc_frontend_domain  = var.frontend_domain
    cc_letsencrypt_mail = var.letsencrypt_mail
    cc_nc_endpoint         = var.nc_endpoint
    cc_nc_sharedsecret     = var.nc_sharedsecret
    cc_turn_sharedsecret   = var.turn_sharedsecret
  })
}

resource "hcloud_floating_ip" "vb_v4" {
  home_location = var.location
  labels        = {}
  name          = "${var.name}-v4"
  type          = "ipv4"
}

resource "hcloud_floating_ip" "vb_v6" {
  home_location = var.location
  labels        = {}
  name          = "${var.name}-v6"
  type          = "ipv6"
}

resource "hcloud_floating_ip_assignment" "vb_v4" {
  floating_ip_id = hcloud_floating_ip.vb_v4.id
  server_id      = hcloud_server.vb.id
}

resource "hcloud_floating_ip_assignment" "vb_v6" {
  floating_ip_id = hcloud_floating_ip.vb_v6.id
  server_id      = hcloud_server.vb.id
}

resource "hcloud_rdns" "float_v4" {
  floating_ip_id = hcloud_floating_ip.vb_v4.id
  ip_address = hcloud_floating_ip.vb_v4.ip_address
  dns_ptr = var.frontend_domain
}

resource "hcloud_rdns" "float_v6" {
  floating_ip_id = hcloud_floating_ip.vb_v6.id
  ip_address = cidrhost(hcloud_floating_ip.vb_v6.ip_network, 1)
  dns_ptr = var.frontend_domain
}
