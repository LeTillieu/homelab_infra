variable "terraform_private_key" {
  description = "Private key to access proxmox server"
  type        = string
  sensitive   = true
}

variable "proxmox_api_token" {
  description = "Token for proxmox API"
  type        = string
  sensitive   = true
}

variable "proxmox_ip" {
  description = "Proxmox ip address"
  type        = string
  sensitive   = true
}

variable "proxmox_port" {
  description = "Proxmox port"
  type        = string
  sensitive   = true
}

variable "debian_url" {
  description = "Debian 12 image URL"
  type        = string
  sensitive   = false
}

variable "debian_sha512" {
  description = "Debian 12 checksum"
  type        = string
  sensitive   = false
}
variable "terraform_allowed_key_public" {
  description = "Public key to allow ssh connection from my computer"
  type        = string
  sensitive   = true
}

variable "k8s_cluster_network_prefix" {
  description = "Public key to allow ssh connection from my computer"
  type        = string
  sensitive   = true
}