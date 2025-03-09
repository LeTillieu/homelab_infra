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


# Create control plane VM
resource "proxmox_virtual_environment_vm" "k8s-ctrlplane_vm" {
  node_name = "proxmox"
  count = 3
  vm_id = 200+count.index
  name = "k8s-ctrlplane-terraform-${count.index}"
  description = "K8sctrlplane managed by terraform"
  tags = ["terraform", "debian", "k3s_server","k3s"]
  stop_on_destroy = true
  on_boot = false
  started = true
  keyboard_layout = "fr"

   cpu {
    cores        = 1
    type         = "x86-64-v2-AES"
  }

  memory {
    dedicated = 2048
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = proxmox_virtual_environment_download_file.debian-12-generic-amd64-daily-20250214-2023.id
    interface    = "scsi0"
    size         = 32
  }
  
  serial_device {}

  network_device {
    model = "virtio"
    bridge = "vmbr0"
    mac_address = format("02:42:ac:11:00:%02x",count.index+1)
  }

  initialization {
    user_account {
      keys = [var.terraform_allowed_key]
      username = "terraform"
    }
  }
}


# Create nodes
resource "proxmox_virtual_environment_vm" "k8s-nodes_vm" {
  count = 4
  node_name = "proxmox"
  vm_id = 210+count.index
  name = "k8s-node-terraform-${count.index}"
  description = "K8s node managed by terraform"
  tags = ["terraform", "debian", "k3s_node","k3s"]
  stop_on_destroy = true
  on_boot = false
  started = true
  keyboard_layout = "fr"

  cpu {
    cores        = 1
    type         = "x86-64-v2-AES"
  }

  memory {
    dedicated = 1024
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = proxmox_virtual_environment_download_file.debian-12-generic-amd64-daily-20250214-2023.id
    interface    = "scsi0"
    size         = 32
  }

  network_device {
    model = "virtio"
    bridge = "vmbr0"
    mac_address = format("02:42:ac:11:01:%02x",count.index+1)
  }
  serial_device {}

  initialization {
    user_account {
      keys = [var.terraform_allowed_key]
      username = "terraform"
    }
  }
}


resource "proxmox_virtual_environment_vm" "postgres-vm" {
  node_name = "proxmox"
  vm_id = 231
  name = "postgres-terraform"
  description = "K8s node managed by terraform"
  tags = ["terraform", "debian", "postgres","db"]
  stop_on_destroy = true
  on_boot = false
  started = true
  keyboard_layout = "fr"

  cpu {
    cores        = 2
    type         = "x86-64-v2-AES"
  }

  memory {
    dedicated = 2048
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = proxmox_virtual_environment_download_file.debian-12-generic-amd64-daily-20250214-2023.id
    interface    = "scsi0"
    size         = 32
  }

  network_device {
    model = "virtio"
    bridge = "vmbr0"
    mac_address = "02:42:ac:11:02:01"
  }
  serial_device {}

  initialization {
    user_account {
      keys = [var.terraform_allowed_key]
      username = "terraform"
    }
  }
}