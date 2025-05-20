variable "SSH_USERNAME" {
  type    = string
  default = "Administrator"
}

variable "SSH_PASSWORD" {
  type    = string
  default = env("PKR_VAR_SSH_PASSWORD")
  sensitive = true
}

variable "PROXMOX_URL" {
  type    = string
  default = null
}

variable "PROXMOX_USERNAME" {
  type    = string
  default = null
}

variable "PROXMOX_TOKEN" {
  type    = string
  default = null
  sensitive = true
}

variable "PROXMOX_NODE" {
  type    = string
  default = null
}


