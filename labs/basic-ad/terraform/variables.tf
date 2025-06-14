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

# templates to clone
variable "WINDOWS_CLIENT_TEMPLATE" {
  type = string
  description = "Windows client template to be cloned"
}

variable "WINDOWS_SERVER_TEMPLATE" {
  type = string
  description = "Windows server template to be cloned"
}

# vm clone IP configs
variable "DNS_NAMESERVER" {
  type = string
  description = "DNS nameserver IP passed to all cloud-init config drives; domain members will be pointed to PDC after deployment"
}

variable "DC01_IP_CONF" {
  type = string
  description = "DC01 IP info passed to cloud-init config drive (ex. ip=192.168.0.2/24,gw=192.168.0.1)"
}

variable "SERVER01_IP_CONF" {
  type = string
  description = "SERVER01 IP info passed to cloud-init config drive (ex. ip=192.168.0.3/24,gw=192.168.0.1)"
}

variable "CLIENT01_IP_CONF" {
  type = string 
  description = "CLIENT01 IP info passed to cloud-init config drive (ex. ip=dhcp)"
}

# name of resulting AD domain
variable "DOMAIN_NAME" {
  type = string
  description = "Domain DNS name passed to ansible (ex. example.local)"
}

# public key path passed via environment variable
# key pair is generated by build.sh
variable "INFRA_SSH_PUBLIC_KEY_PATH" {
  type = string
  default = "/dev/null"
  description = "Public SSH key filepath; contents read and passed to cloud-init config drives"
}

locals {
  INFRA_USER_SSH_PUBLIC_KEY = file(var.INFRA_SSH_PUBLIC_KEY_PATH)
}
