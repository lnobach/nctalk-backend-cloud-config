
provider "hcloud" {
  token = var.hcloud_token
}

data "hcloud_ssh_keys" "my_keys" {
  with_selector = var.ssh_key_selector
}

resource "hcloud_primary_ip" "vb-ip6" {
  name          = "${var.name}-ip6"
  datacenter    = "fsn1-dc14"
  type          = "ipv6"
  assignee_type = "server"
  auto_delete   = false
  labels = {
    "usage" : var.name
  }
}

resource "hcloud_primary_ip" "vb-ip4" {
  name          = "${var.name}-ip4"
  datacenter    = "fsn1-dc14"
  type          = "ipv4"
  assignee_type = "server"
  auto_delete   = false
  labels = {
    "usage" : var.name
  }
}

resource "hcloud_rdns" "vb-rdns4" {
  primary_ip_id = hcloud_primary_ip.vb-ip4.id
  ip_address    = hcloud_primary_ip.vb-ip4.ip_address
  dns_ptr       = var.backend_domain
}

resource "hcloud_rdns" "vb-rdns6" {
  primary_ip_id = hcloud_primary_ip.vb-ip6.id
  ip_address    = cidrhost(hcloud_primary_ip.vb-ip6.ip_network, 1)
  dns_ptr       = var.backend_domain
}


resource "hcloud_server" "vb" {
  image = "rocky-10"
  labels = {
    "usage" : var.name
  }
  location    = var.location
  name        = var.name
  server_type = "cx23"
  ssh_keys    = data.hcloud_ssh_keys.my_keys.ssh_keys.*.id
  user_data = templatefile("${path.module}/../../cloud-config.template.yaml", {
    cc_backend_domain    = var.backend_domain
    cc_letsencrypt_mail  = var.letsencrypt_mail
    cc_nc_endpoint       = var.nc_endpoint
    cc_nc_sharedsecret   = var.nc_sharedsecret
    cc_turn_sharedsecret = var.turn_sharedsecret
    cc_ssh_port          = var.ssh_port
  })
  public_net {
    ipv4_enabled = true
    ipv4         = hcloud_primary_ip.vb-ip4.id
    ipv6_enabled = true
    ipv6         = hcloud_primary_ip.vb-ip6.id
  }
}
