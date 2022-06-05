
variable "hcloud_token" {
  description = "Hetzner Cloud token (can be obtained from the console)"
}

variable "frontend_domain" {
  description = "The domain name used for frontend access. Required for ACME/Let's Encrypt"
}
variable "letsencrypt_mail" {
  description = "E-Mail address passed to Let's Encrypt"
}

variable "location" {
  description = "Location of VM and elastic IPs"
  default     = "fsn1"
}

variable "nc_endpoint" {}

variable "nc_sharedsecret" {}

variable "turn_sharedsecret" {}

variable "ssh_port" {
  description = "SSH admin port"
  default     = "22"
}

variable "name" {
  description = "Name (prefix) of the infrastructure components"
  default     = "vb"
}

variable "ssh_key_selector" {
  description = "The SSH key selector which will be used for login - see https://docs.hetzner.cloud/#overview-label-selector"
  default     = "purpose=admin"
}
