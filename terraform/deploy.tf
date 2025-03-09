terraform {
  backend "gcs" {
    bucket = "homelab_terraform"
    prefix = "terraform/state"
  }
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.71.0"
    }
  }
}

provider "proxmox" {
  endpoint = "https://${var.proxmox_ip}:${var.proxmox_port}"
  insecure = true
  api_token = var.proxmox_api_token
  ssh {
    username = "terraform-prov"
    private_key = var.terraform_private_key
    node  {
      name = "proxmox"
      address = var.proxmox_ip
    }
  }
}

resource "proxmox_virtual_environment_download_file" "debian-12-generic-amd64-daily-20250214-2023" {
  content_type       = "iso"
  datastore_id       = "local"
  file_name          = "debian-12-generic-amd64-daily-20250214-2023.img"
  node_name          = "proxmox"
  url                = var.debian_url
  checksum           = var.debian_sha512
  checksum_algorithm = "sha512"
  overwrite          = true
}
