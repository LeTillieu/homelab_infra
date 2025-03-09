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
  description = "Proxmox port"
  type        = string
  sensitive   = false
}

variable "debian_sha512" {
  description = "Proxmox port"
  type        = string
  sensitive   = false
}