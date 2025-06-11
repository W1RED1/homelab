# PVE target/auth vars
# token ID and secret prompted at runtime
variable "PROXMOX_URL" {
  type = string
  description = "PVE API entrypoint URL (ex. https://127.0.0.1:8006/api2/json)"
}

variable "PROXMOX_NODE" {
  type = string
  description = "PVE node which clones will live on"
}

variable "PROXMOX_TOKEN_ID" {
  type = string
  description = "PVE API token ID (ex. username@pve!tokenname)"
}

variable "PROXMOX_TOKEN_SECRET" {
  type = string
  description = "PVE API token UUID secret (ex. 00000000-0000-0000-0000-000000000000)"
  sensitive = true
}

# SSH communicator vars
variable "SSH_USERNAME" {
  type = string
  description = "SSH username for configuring template VMs"
}

variable "SSH_PASSWORD" {
  type = string
  description = "SSH password for configuring template VMs"
  sensitive = true
}

# template metadata vars
variable "TEMPLATE_POOL" {
  type = string
  description = "PVE pool which templates will be added to"
}

variable "TEMPLATE_TIMESTAMP" {
  type = string
  description = "Timestamp of template build appended to description"
}
