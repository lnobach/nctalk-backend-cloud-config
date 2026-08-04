terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">= 1.68"
    }
  }
  required_version = ">= 1.14"
}
