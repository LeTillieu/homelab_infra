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
