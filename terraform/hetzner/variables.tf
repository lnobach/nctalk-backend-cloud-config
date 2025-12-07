
variable "hcloud_token" {
  description = "Hetzner Cloud token (can be obtained from the console)"
}

variable "backend_domain" {
  description = "The domain name used for accessing the backend. Required for ACME/Let's Encrypt"
}
variable "letsencrypt_mail" {
  description = "E-Mail address passed to Let's Encrypt"
}

variable "location" {
  description = "Location of VM and elastic IPs"
  default     = "fsn1"
}

variable "nc_endpoint" {
  description = "The domain name of your Nextcloud instance using this backend."
}

variable "nc_sharedsecret" {
  description = "The shared secret used between Nextcloud and the backend instance. Must be set equally in your Talk settings in Nextcloud."
}

variable "turn_sharedsecret" {
  description = "The shared secret for the TURN server. Must be set equally in your Talk settings in Nextcloud."
}

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
